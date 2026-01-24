Lab Notes
  1. **Goal:**
       -Deploy a SOC-style monitoring VM for lab traffic.
  2. **What I built:**
       -Security onion Eval architecture and 2 NIC, 200gb storage, 12gb RAM 
  3. **Architecture**
  4. **Install Decisions:**
      -Limited hardware; EVAL consolidates manager/search/sensor roles.
  5. **Issues & => Fixes**
      -cant fetch os URL => download iso instead
  7. **Lessons Learned**
       -Virtual switches must allow MAC spoofing for IDS sensors.
