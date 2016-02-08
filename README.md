# Dovetail

Dovetail *ahem* dovetails Elixir and dovecot. It's raison d'être is to control a
dovecot server for IMAP testing.

Dovetail is an Elixir library that lets you:

- install a rootless dovecot server for testing
- an Elixir API to interact with the dovecot server (`Dovetail`)
- start and stop a dovecot server (`Dovetail.Process`)
- create and remove dovecot users (`Dovetail.UserStore`)
- send an email to a particular dovecot user (`Dovetail.Deliver`)
- all possible via a remote node, because Erlang

## Usage

### Dovecot

Dovetail requires dovecot. To setup a
[rootless install](http://wiki2.dovecot.org/HowTo/Rootless) of dovecot, simply
run:

```shell
$ make
```

and then let yourself get distracted. It's going to take awhile for it to
download and compile dovecot.

#### Configuration

Dovecot's `dovecot.conf` must be generated before starting the mail server. There
are two ways to call the necessary `Dovecot.Config` code.

From within an Elixir VM:

```elixir
Dovetail.config()
```

Or, using the mix task:

```shell
mix dovetail.config
```

The `dovecot.conf` file is templated from `priv/dovecot.conf.eex`.

### Dovetail

Dovetail can be used as a library, application, or command-line tool via mix.

#### User Store

The Dovetail library must have access to whatever `UserStore` resource it is
trying to access. For example, if you're using a `UserStore.PasswordFile`, the
node must be able to read and write to the file specified by path.

Dovecot must also be configured to correctly use that resource. See

- `Dovetail.UserStore.PasswordFile`

### More

You can read more usage notes in the source code documentation for the various
Dovetail components. Start with:

```elixir
iex> h Dovetail
```

## License + Copyright

Dovetail may be redistributed according to the BSD 3-Clause License.

Copyright (c) 2015, ThusFresh Inc
