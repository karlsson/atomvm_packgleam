//// Main module 

import gleam/io
import gleam/list
import simplifile
import tom

/// Usage: `gleam run -m atomvm_packgleam`
pub fn main() {
  let assert Ok(gleamtoml) = simplifile.read("gleam.toml")
  let assert Ok(parsedtom) = tom.parse(gleamtoml)
  let assert Ok(appname) = tom.get_string(parsedtom, ["name"])
  case packbeam(appname) {
    Ok(Nil) -> {
      io.println("The following files were included in the avm file:")
      list.each(listavm(appname), fn(a) { io.println(a) })
    }
    Error(reason) -> io.println("Error: " <> reason)
  }
}

@external(erlang, "atomvm_packgleam_ffi", "packbeam")
fn packbeam(app: String) -> Result(Nil, String)

@external(erlang, "atomvm_packgleam_ffi", "list")
fn listavm(app: String) -> List(String)
