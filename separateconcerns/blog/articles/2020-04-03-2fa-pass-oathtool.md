% Two-factor authentication with pass and oathtool
% Pierre 'catwell' Chapuis
% 2020-04-03 09:05:00

    ::description::
    How to use pass and oathtool to generate 2FA codes easily.

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
