-module(atomvm_packgleam_ffi).
-export([packbeam/1, list/1]).

-spec packbeam(binary()) -> {ok, nil} | {error, string()}.
packbeam(AppNameBinary) ->
    AppName = binary_to_list(AppNameBinary),
    Options =
    #{
        prune => true,
        start_module => binary_to_atom(AppNameBinary),
        application_module => binary_to_atom(AppNameBinary),
        include_lines => false
    },
    OutPath = avmfile(AppName),
    try
        packbeam_api:create(OutPath,
                            beam_paths([AppName] ++ 
                                        get_applications(AppName)),
                            Options)
    of
      ok ->
        io:format("Avm file written to ~s~n", [OutPath]),
        {ok, nil};
      _ ->
        {error, << "Unkown fault"/utf8 >> }
    catch
        throw:Reason ->
            {error, list_to_binary(Reason)}
    end.

-spec list(binary()) -> [[string()]].
list(AppNameBinary) ->
  [packbeam_api:get_element_name(E) || E <- packbeam_api:list(avmfile(binary_to_list(AppNameBinary)))].

%% ------------- Internal functions -----------

avmfile(AppName) -> base_dir(AppName) ++ AppName ++ ".avm".

base_dir(AppName) -> "build/dev/erlang/" ++ AppName ++ "/".

ebin_dir(AppName) -> base_dir(AppName) ++ "/ebin/".

beam_paths([]) ->
    [];
beam_paths([App|T]) ->
    beam_path(App) ++ beam_paths(T).

beam_path(AppName) ->
    {ok, As} = file:list_dir(ebin_dir(AppName)),
    [ebin_dir(AppName) ++ A ||
        A <- As,
        string:find(A, ".beam", trailing) /= nomatch].

get_applications(AppName) ->
    AppAtom = list_to_atom(AppName),
    {ok, [{application, AppAtom, Pars}|_]} =
        file:consult(ebin_dir(AppName) ++ AppName ++ ".app"),
    [atom_to_list(A) || A <- proplists:get_value(applications, Pars)].
