# Dovetail

Dovetail *ahem* dovetails Elixir and dovecot. It's raison d'être is to control a
dovecot server for IMAP testing.

Dovetail is an Elixir library that lets you:

- install a rootless dovecot server for testing
- interact with a dovecot server via Elixir (`Dovetail`)
- start and stop a dovecot server (`Dovetail.Process`)
- create and remove dovecot users (`Dovetail.UserStore`)
- send an email to a particular dovecot user (`Dovetail.Deliver`)
- all possible via a remote node, because Erlang

## Install

### Dovecot

Dovetail requires dovecot. To setup a
[rootless install](http://wiki2.dovecot.org/HowTo/Rootless) of dovecot, simply
run:

```shell
$ mix dovetail.make
```

and then let yourself get distracted. It's going to take awhile for it to
download and compile dovecot.

### Dovetail

Fetch Dovetail's dependencies and compile it all:

```shell
$ mix deps.get
$ mix compile
```

### Configuration

Dovecot's `dovecot.conf` must be generated before starting the mail server. This
will be done implicitly if you start the `:dovetail` application or call
`Dovetail.ensure/1`. 

There are two ways to explicitly call the necessary `Dovecot.Config` code. From
within an Elixir VM:

```elixir
iex> Dovetail.config()
```

Or, using the mix task:

```shell
$ mix dovetail.config
```

The `dovecot.conf` file is templated from `priv/dovecot.conf.eex`.

## Usage

Dovetail can be used as a library, application, or mix command-line tool.

### IEx Shell

Start an IEx shell by calling:

```shell
$ iex -S mix
```

The `:dovetail` application, along with the dovecot server, should start with
the mix application. You can check this with `Dovetail.up?/0`

```elixir
iex> Dovetail.up?
true
```

### Documentation

You can read more usage notes in the source code documentation for the various
Dovetail components. Start with checking the documentation from the IEx shell:

```elixir
iex> h Dovetail
```

You can also build the documentation into neat and trim HTML:

```shell
$ mix docs
```

### User Store

The Dovetail library must have access to whatever `UserStore` resource it is
trying to access. For example, if you're using a `UserStore.PasswordFile`, the
node must be able to read and write to the file specified by path.

Dovecot must also be configured to correctly use that resource. See

- `Dovetail.UserStore.PasswordFile`

## License + Copyright

Dovetail may be redistributed according to the BSD 3-Clause License.

Copyright (c) 2015, ThusFresh Inc
