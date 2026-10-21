# Where each requirement lives

A map for the defence: requirement → file and line.

## Model
| R | Where |
|---|---|
| R1 immutable, `copyWith`, names not mutable | [shift.dart](../lib/models/shift.dart) — `const Shift(...)`, `get volunteers` returns `List.unmodifiable` (line 50); [profile.dart](../lib/models/profile.dart) |
| R2 colour by exhaustive switch | [cause.dart:17](../lib/models/cause.dart) |
| R3 `Item.empty()` / `Profile.empty()` | [shift.dart:21](../lib/models/shift.dart), [profile.dart:5](../lib/models/profile.dart) |
| R4 derived getters | `count`, `freePlaces`, `isFull`, `isPast`, `contains` in [shift.dart](../lib/models/shift.dart) |
| R5 record `places`, destructured | [shift.dart:59](../lib/models/shift.dart); destructured in [shift_avatar.dart](../lib/widgets/shift_avatar.dart) and `_AboutTab` in [detail_screen.dart](../lib/screens/detail_screen.dart) |
| R6 `notes` with collection `if`, no `!` | `_AboutTab` in [detail_screen.dart](../lib/screens/detail_screen.dart) |
| R7 where/map/fold/any, sort a copy | [shifts_tab.dart:46](../lib/screens/shifts_tab.dart), [favourites_tab.dart](../lib/screens/favourites_tab.dart) (`any`), [profile_tab.dart:83](../lib/screens/profile_tab.dart) (`fold`) |
| R8 own date format, `padLeft` | [format.dart](../lib/utils/format.dart) |
| R9 sealed `Countdown` | [countdown.dart](../lib/models/countdown.dart); rendered by `switch` in `_Header`, [detail_screen.dart](../lib/screens/detail_screen.dart) |

## Shell
| R | Where |
|---|---|
| R10 list and profile in shell State | [shell.dart:32](../lib/screens/shell.dart) |
| R11 ThemeMode in MyApp | [main.dart:18](../lib/main.dart) → `Shell` → `ProfileTab` |
| R12 setState wraps only the change | everywhere; awaits and dialogs come before it |
| R28 one Navigator, tab switch via shell callback | `onOpenProfile`, `onBrowse` → `_selectTab` in [shell.dart](../lib/screens/shell.dart) |
| R32 Drawer: About, Reset | [app_drawer.dart](../lib/widgets/app_drawer.dart), `_about` / `_reset` in [shell.dart](../lib/screens/shell.dart) |

## Tab 1
| R | Where |
|---|---|
| R21 search, chips, past filter, Expanded list | [shifts_tab.dart](../lib/screens/shifts_tab.dart) |
| R18 one card | [shift_card.dart](../lib/widgets/shift_card.dart) |
| R19 Stack avatar + Positioned badge | [shift_avatar.dart](../lib/widgets/shift_avatar.dart) |
| R20 list / grid by LayoutBuilder | [shift_collection.dart:33](../lib/widgets/shift_collection.dart) |
| R23 shared empty state, FAB | [empty_state.dart](../lib/widgets/empty_state.dart); FAB in [shell.dart](../lib/screens/shell.dart) |

## Detail
| R | Where |
|---|---|
| R24 Stack header with asset image | `_Header`, [detail_screen.dart](../lib/screens/detail_screen.dart); asset in [pubspec.yaml](../pubspec.yaml) |
| R13 Timer in initState / dispose | [detail_screen.dart:34](../lib/screens/detail_screen.dart), line 41 |
| R29 DefaultTabController, live count | [detail_screen.dart:138](../lib/screens/detail_screen.dart) |
| R15 confirm with `showDialog<bool>`, SnackBar → profile | `_join` in [detail_screen.dart](../lib/screens/detail_screen.dart) |
| R16 `onPressed: null`, opposite action | `_primaryAction` in [detail_screen.dart:123](../lib/screens/detail_screen.dart) |
| R26 route arguments | `DetailArgs`, `FormArgs` in [routes.dart](../lib/routes.dart) |
| R31 no back arrow written, menu Edit/Delete | `PopupMenuButton` in [detail_screen.dart](../lib/screens/detail_screen.dart) |

## Form
| R | Where |
|---|---|
| R33 Form + GlobalKey, one validate() | `_save` in [form_screen.dart](../lib/screens/form_screen.dart) |
| R34 validators | `_validate*` methods in [form_screen.dart](../lib/screens/form_screen.dart) |
| R35 controllers / FocusNodes as fields | top of `_FormScreenState` |
| R36 readOnly date and time, pickers | `_pickDate`, `_pickTime` |
| R37 scrolling form | `SingleChildScrollView` + `Column` |
| R17 one-second save | `_save`, `_saving` |
| R30 PopScope, dirty = values ≠ initial values | [form_screen.dart:244](../lib/screens/form_screen.dart), `_values` at line 87 |
| R27 caller awaits `pushNamed<Shift>` | `_create` in [shell.dart](../lib/screens/shell.dart), `_edit` in [detail_screen.dart](../lib/screens/detail_screen.dart) |
| R14 `mounted` after every await | every `async` method |

## Tabs 2–3, routes, engineering
| R | Where |
|---|---|
| R38 profile controllers, RegExp group, "on N lists" | [profile_tab.dart](../lib/screens/profile_tab.dart) |
| R22 fromSeed, three ThemeMode chips | [theme.dart](../lib/theme.dart), [profile_tab.dart](../lib/screens/profile_tab.dart) |
| R25 Routes, onGenerateRoute, onUnknownRoute | [routes.dart](../lib/routes.dart) |
| R39 no packages, analyze clean | [pubspec.yaml](../pubspec.yaml) |
| R40 commits | `git log --oneline` |
| R41 README | [README.md](../README.md) |
