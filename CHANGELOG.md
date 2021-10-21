# CHANGELOG

## v1.03
This update comes courtesy of the fixes provided by Dargino.
- New handheld items are supported, including Search And Destroy DLC items
- Heal command has been updated to work with the new `server.getCharacterData()` function

## v1.02
- Fixed issue where dedicated server owners could not be made owners

## v1.01
-	Fixed error when attempting to heal a player that is not on the server.
- Corrected punctuation for `?player_perms` command.
- Disabling "map teleport" ("Allow Teleport" in the custom options menu) prevents non admin/owner players from teleporting.

- Added `?deny_tp` command that blocks another player from teleporting to you (Admins can override this).
