% Two-factor authentication with pass and oathtool
% Pierre 'catwell' Chapuis
% 2020-04-03 09:05:00

<!--@
  description = "How to use pass and oathtool to generate 2FA codes easily."
  updated = "2020-04-03 16:20:00"
-->

If you're like me, you don't want to depend on your phone to log into a website, and you wish [your favorite password manager](https://www.passwordstore.org) would support 2FA. Well, it can.

When asked to setup 2FA on a website, get a text code. If the website doesn't give you that option, just use [zbar](http://zbar.sourceforge.net). For instance, with the QR code from the [GitHub documentation](https://help.github.com/en/github/authenticating-to-github/configuring-two-factor-authentication):

    $ zbarimg totp-click-enter-code.png
    QR-Code:otpauth://totp/GitHub:LyaLya?secret=qmli3dwqm53vl7fy&issuer=GitHub
    scanned 1 barcode symbols from 1 images in 0.03 seconds

Once you get the secret, put the command line to generate a code using [oathtool](https://www.nongnu.org/oath-toolkit/oathtool.1.html) in `2fa/github` in `pass` like this:

    oathtool --totp --base32 qmli3dwqm53vl7fy

Finally, add this to your `.bashrc` (or the equivalent for whatever shell you use):

    2fa () { eval $(pass 2fa/$1) ; }

You can now get your 2FA codes like this:

    $ 2fa github
    795864

All the tools used in that article are [available](https://www.archlinux.org/packages/community/any/pass/) [as](https://www.archlinux.org/packages/community/x86_64/oath-toolkit/) [packages](https://www.archlinux.org/packages/extra/x86_64/zbar/) in the Arch Linux repositories.

## Complements

It was [a post on Lobsters](https://lobste.rs/s/abmkdz/2fa_2_factor_authentication_terminal_app) that prompted me to post this. [Someone from the comments](https://lobste.rs/s/abmkdz/2fa_2_factor_authentication_terminal_app#c_c0y9io) and [a former colleague on Twitter](https://twitter.com/gawenr/status/1245973593453932544) told me about [a pass extension](https://github.com/tadfisher/pass-otp) I didn't know about which does almost the same thing.

Also, some people think that putting 2FA codes in a password manager defeats the purpose. But in practice TOTP 2FA does not really add much more to the security of my accounts than the strong random passwords I generate with pass. The "second factor" part isn't really the true benefit.

One actual advantage is that nobody on the network can sniff all of my credentials (like digest-based password verification methods). Another, and I think this is the main one, is that the owner of the website has chosen part of the credentials and hence ensured some degree of strength. What I do preserves both of those properties, so I'm fine with it. By the way, note that password managers like 1Password [do the same thing](https://support.1password.com/one-time-passwords/).

The one thing I could do to really improve the security of the whole thing is use 2FA *to access pass* by storing my GPG key in a Yubikey. I probably will, someday.
