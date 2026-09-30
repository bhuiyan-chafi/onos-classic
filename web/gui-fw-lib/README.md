# GuiFwLibApp

This project separates out the Framework part of the ONOS GUI project into a separate Angular library.

It is separate to the main ONOS GUI project which is in `~/onos/web/gui`.

It allows external applications to use it, without bringing along the whole of the GUI.

The Bazel build of this library handles the building and packaging of the library
so that other projects and libraries can use it.

## Development server
To build the `npm` library project using Bazel run:
`bazel build //web/gui-fw-lib:gui-fw-lib-npm`
inside the `~/onos` folder.

To make the library in to an NPM package use
`bazel run //web/gui-fw-lib:gui-fw-lib-npm.pack`

## Code scaffolding

Run `bazel run @npm//:node_modules/@angular/cli/bin/ng generate component component-name --project=gui-fw-lib`
to generate a new component. You can also use
`bazel run @npm//:node_modules/@angular/cli/bin/ng generate directive|pipe|service|class|guard|interface|enum|module`.

## Running unit tests
Run `bazel test //web/gui-fw-lib:test-not-coverage` to execute the unit tests via [Karma](https://karma-runner.github.io).
