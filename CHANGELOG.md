# CHANGELOG

## v6.7.0 (2024-03-29)

### 🎉 New

* Implemented support for multi-point navigation within the route drawing feature. Customized waypoint icons have been updated to utilize `waypointInfos` in lieu of `startIcon` and `endIcon`. Additionally, the `isAddViaDash` attribute has been introduced to govern the inclusion of dashed segments at waypoints.
* The `MXMPainterPathDto` class now incorporates the original `waypoints` attribute, and will subsequently deprecate the `startPoint` and `endPoint` attributes.
