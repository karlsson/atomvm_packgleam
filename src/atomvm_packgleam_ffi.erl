-module(atomvm_packgleam_ffi).
-export([packbeam/2, list/1]).

-spec packbeam(binary(), [binary()]) -> {ok, nil} | {error, string()}.
packbeam(AppNameBinary, DepsBinaryList) ->
    AppName = binary_to_list(AppNameBinary),
    Deps = [binary_to_list(A) || A <- DepsBinaryList],
    AllApps = [AppName | Deps],
    Options =
        #{
          prune => true,
          start_module => binary_to_atom(AppNameBinary),
          application_module => binary_to_atom(AppNameBinary),
          include_lines => false
         },
    OutPath = avmfile(AppName),
    try
        file:set_cwd(build_dir()),
        packbeam_api:create(OutPath,
                            get_priv_dir_files(AllApps)
                            ++ app_paths(AllApps)
                            ++ beam_paths(),
                            Options)
    of
        ok ->
            io:format("Avm file written to ~s~n", [build_dir() ++ OutPath]),
            {ok, nil};
        _ ->
            {error, << "Unkown fault"/utf8 >> }
    catch
        throw:Reason ->
            io:format("Error: ~p~n", [Reason]),
            {error, <<"packgleam error!">>}
    end.

-spec list(binary()) -> [[string()]].
list(AppNameBinary) ->
    [packbeam_api:get_element_name(E) ||
        E <- packbeam_api:list(avmfile(binary_to_list(AppNameBinary)))].

%% ------------- Internal functions -----------

avmfile(AppName) -> base_dir(AppName) ++ AppName ++ ".avm".

build_dir() -> "build/dev/erlang/".

base_dir(AppName) -> AppName ++ "/".

ebin_dir(AppName) -> base_dir(AppName) ++ "ebin/".

priv_dir(AppName) -> base_dir(AppName) ++ "priv/".

%% app_file(AppName) -> ebin_dir(AppName) ++ AppName ++ ".app".

beam_paths() ->
    filelib:wildcard( "*/ebin/" ++ "*.beam").

app_paths([]) ->
    [];
app_paths([App|T]) ->
    app_path(App) ++ app_paths(T).

app_path(AppName) ->
    filelib:wildcard(ebin_dir(AppName) ++ "*.app").

get_priv_dir_files([]) ->
    [];
get_priv_dir_files([H|T]) ->
    get_priv_dir_files1(H) ++ get_priv_dir_files(T).

get_priv_dir_files1(AppName) ->
    [ X || X <- filelib:wildcard(priv_dir(AppName) ++"**"),
           not filelib:is_dir(X)].
