# Sysadmin Collective

This is the documentation of the Delta Chat sysadmin collective. 

You can contact us at: 

In the folders, you can find the documentation of how our services are set up.
This document describes some of our best practices and high-level ideas.

## Best Practices

### SSH

Shell login is protected by SSH. We allow login only with a public key, not
with a password. You can't login as root. The port is 22. Everyone gets their
own user for login.

You need to save the password of at least one user with sudo rights. This way,
you can recover from a bad SSH configuration through login via the web
interface. (at least that's possible with greenhost and hetzner).

For the other users, the password can be a long random string, they won't need
it anyway.

### sudo

As you don't need/can't use a password for login, sudo is password-less as
well.

### etckeeper

All changes in the server config should be tracked with etckeeper. This way,
others can follow the changes you make. Good commit messages are important.

### Backup & Restore

We have full backups of each server each night, which can be restored quickly.
They are done with borgbackup scripts, to a Hetzner backup space.

Restore is only tested for support.delta.chat. You can follow this example if
you need to restore this or another service:
https://github.com/deltachat/sysadmin/tree/master/backup#restore-migration-to-hetzner-cloud

