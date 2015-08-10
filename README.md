# Dovetail

Dovetail *ahem* dovetails with dovecot and IMAP client testing.

Dovetail's is an Elixir API that lets you:

- start and stop a dovecot server
- create and remove dovecot users
- send an email to a particular dovecot user
  ... and verify its arrival? prob.
- all possible via a remote node

## Usage

### Dovecot

Dovetail requires dovecot. To setup a
[rootless install](http://wiki2.dovecot.org/HowTo/Rootless) of dovecot, simply
run:

```shell
$ make
```

and then let yourself get distracted. That's going to take awhile.

### Dovetail

The dovetail application must have access to whatever `UserStore` resource it is
trying to access. For example, if you're using a `UserStore.PasswordFile`, the
node must be able to read and write to the file specified by path.

Dovecot must also be configured to correctly use that resource. See

- `Dovetail.UserStore.PasswordFile`

### More

You can read more usage notes in the source code documentation for the various
dovetail components. Start with

```elixir
iex> h Dovetail
```

## License + Copyright

Dovetail may be redistributed according to the BSD 3-Clause License.

Copyright (c) 2015, ThusFresh Inc
