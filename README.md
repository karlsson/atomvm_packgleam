# atomvm_packgleam

[![Package Version](https://img.shields.io/hexpm/v/atomvm_packgleam)](https://hex.pm/packages/atomvm_packgleam)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/atomvm_packgleam/)

The atomvm_packgleam library is just a standalone utility that can be added to your gleam project dependencies
in order to create a packed `.avm` file of your project for the [AtomVM](https://www.atomvm.net/) machine
to be flashed onto your IoT device.
```sh
gleam add atomvm_packgleam@1
```
The utility is using the AtomVM [`packbeam`](https://www.atomvm.net/doc/main/atomvm-tooling.html#atomvm-packbeam)
tool.

## Development
Your main module, named the same as your project, will need a `pub fn start() { ... }` function that
AtomVM uses as entry point to start the application.
```gleam
import gleam/io

// Gleam run start
pub fn main() {
  io.println("Hello from gleam run!")
}

// For AtomVM start
// Start the application, callback for AtomVM init.
pub fn start() {
  io.println("Hello from AtomVM!")
}
```

To create the `avm` file execute:
```sh
gleam run -m atomvm_packgleam  # Create an `<application>.avm` file
```
The file name is picked from the `name` attribute in your `gleam.toml` file.

In order to flash, check the AtomVM [documentation](https://www.atomvm.net/doc/main/getting-started-guide.html)
for the available devices.

Further documentation can be found at <https://hexdocs.pm/atomvm_packgleam>.
