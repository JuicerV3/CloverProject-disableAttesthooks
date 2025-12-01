# CloverProject-disableAttesthooks

**_I've lost my documentations so ill let ai explain from this source, probably not gonna be in full details._**

## Components

### DisableCloverKeyboxOverlay

This directory contains a **Runtime Resource Overlay (RRO)** designed to neutralize the keybox attestation check.

#### How it works

The Clover ROM implementation checks for "certified" keyboxes by reading a string array resource named `config_certifiedKeybox` from the framework resources (`android` package).

This overlay works by:

1.  **Targeting the Android Framework**: The `AndroidManifest.xml` specifies `targetPackage="android"`.
2.  **Overriding the Resource**: It defines a new `res/values/arrays.xml` that overrides `config_certifiedKeybox` with an **empty array**.

```xml
<!-- res/values/arrays.xml -->
<resources>
    <string-array name="config_certifiedKeybox" translatable="false">
        <!-- Empty array effectively disables the check -->
    </string-array>
</resources>
```

When the system loads the framework resources, it prioritizes this overlay. Consequently, the attestation hook retrieves an empty list of certified keyboxes, effectively disabling the restriction logic that relies on matching against this list.

#### Building

A build script is provided to compile the overlay into an APK.

```bash
cd DisableCloverKeyboxOverlay
./build.sh
```

This will generate `build/DisableCloverKeyboxOverlay.apk`, which can be installed as a system overlay (e.g., via a Magisk module).
