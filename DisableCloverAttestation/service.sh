#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script and module is placed.
# This will make sure your module will still work if Magisk changes its mount point in the future
MODDIR=${0%/*}

# Wait for boot to complete (optional but good practice for settings)
while [ "$(getprop sys.boot_completed)" != "1" ]; do
  sleep 1
done

# Disable Prop Spoofing by setting pif_data to empty JSON object
# This causes PropImitationHooks to see an empty list of props to spoof.
settings put secure pif_data "{}"

# Disable Keybox Blocking by setting gms_cert_chain to 1
# This causes KeyProviderManager to allow keybox access even if Play Integrity is detected.
settings put secure gms_cert_chain 1

# Disable Keybox Spoofing (Poisoning)
# We provide a valid XML structure so KeyProviderManager loads it, but with invalid key data.
# This causes KeyboxUtils to throw an exception when parsing the keys, which is caught by
# KeyboxImitationHooks, causing it to return the original certificate chain unmodified.
POISON_XML='<Keybox><NumberOfKeyboxes>1</NumberOfKeyboxes><Key algorithm="ecdsa"><PrivateKey format="pem">INVALID</PrivateKey><Certificate format="pem">INVALID</Certificate></Key><Key algorithm="rsa"><PrivateKey format="pem">INVALID</PrivateKey><Certificate format="pem">INVALID</Certificate></Key></Keybox>'
settings put secure keybox_data "$POISON_XML"

