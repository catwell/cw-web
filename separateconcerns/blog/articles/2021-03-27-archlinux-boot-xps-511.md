% Booting GDM on my XPS with kernel 5.11
% Pierre 'catwell' Chapuis
% 2021-03-27 20:15:00

    ::description::
    If you cannot boot into GDM on Arch Linux with Linux kernel 5.11 on an XPS with an Intel graphics card, enable early KMS.

When I updated my Linux kernel to 5.11 I had the bad surprise to end up with a blinking underscore on reboot. It had been many years since an update had broken my system like that. I fixed it rather easily by booting in rescue mode and downgrading the kernel. I had no time to investigate so I just added `linux` to `IgnorePkg` at the time, But I don't use Arch to run old kernels so today I took the time to fix it "properly".

To do so, I reproduced the issue, then downgraded again and looked at the logs with `journalctl -b --boot=-1`. It quickly let me understand that it was GDM that was failing due to something wrong with graphics initialization.

To keep things short, let me skip to the conclusion: if you run into this issue on an old-ish Dell XPS with an Intel Iris Plus 640 graphics card like mine with GDM, Arch and Wayland (or something similar), try [enabling early KMS](https://wiki.archlinux.org/index.php/kernel_mode_setting#Early_KMS_start) by adding `i915` to the `MODULES` array in `mkinitcpio.conf` and rebuilding the initramfs, that fixed it for me.
