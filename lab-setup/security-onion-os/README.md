This is to setup security onion os as layer of defense and analysis for my network

    Goal: -Deploy a SOC-style monitoring VM for lab traffic.
    What I built: -Security onion Eval architecture and 2 NIC, 200gb storage, 12gb RAM
    Architecture
    Install Decisions: -Limited hardware; EVAL consolidates manager/search/sensor roles.
    Issues & => Fixes -cant fetch os URL => download iso instead
    Lessons Learned -Virtual switches must allow MAC spoofing for IDS sensors.

