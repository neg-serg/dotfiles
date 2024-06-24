{
  ...
}: {
  programs.dircolors = {
    enable = true;
    settings = {
        # Partially inspired by https://github.com/trapd00r/LS_COLORS
        COLOR = "all";
        OPTIONS = "-F -b -T 0";
        EIGHTBIT = "1";

        NORMAL                = "00";                     # No color code at all
        FILE                  = "00";                     # Regular file: use no color at all
        RESET                 = "00";                     # Reset to "normal" color
        DIR                   = "07;38;5;234;48;5;25";    # Directory
        SOCK                  = "01;38;5;075";            # Socket
        BLK                   = "38;5;24";                # Block device driver
        CHR                   = "38;5;24;1";              # Character device driver
        CAPABILITY            = "38;5;17";                # File with capability
        NORM                  = "00";                     # Normal files
        EXEC                  = "04;03";                  # This is for files with execute permission
        FIFO                  = "38;5;126";               # Named pipe
        DOOR                  = "38;5;127";               # Solaris door
        LINK                  = "03;38;5;05";             # Symbolic link
        ORPHAN                = "01;03;38;5;196;48;5;52"; # Symbolic link to nonexistent file
        MULTIHARDLINK         = "48;5;233;38;5;7;1;3";    # Regular file with more than one link
        OTHER_WRITABLE        = "48;5;233;38;5;7;1;3";    # Dir that is other-writable o+w and not sticky
        SETGID                = "38;5;37;1";              # File that is setgid: g+s
        SETUID                = "38;5;37";                # File that is setgid: u+s
        STICKY                = "38;5;86;48;5;234";       # Dir with the sticky bit set +t and not other-writable
        STICKY_OTHER_WRITABLE = "38;5;86;48;5;234;1";     # Dir that is sticky and other-writable
        
        "*dircolors" =  "48;5;89;38;5;197;1;3;4;7"; # :-)
        "*dir_colors" = "48;5;89;38;5;197;1;3;4;7"; # :-)
        
        # ┌───────────────────────────────────────────────────────────┐
        # │ Plain text                                                │
        # └───────────────────────────────────────────────────────────┘
        ".lesshst" =        "01;38;5;248"; # Plain text
        ".log" =            "01;38;5;238"; # Plain text (logs)
        ".map" =            "01;38;5;248"; # Plain text
        ".nfo" =            "01;38;5;248"; # Plain text
        ".txt" =            "00;38;5;248"; # Plain text
        # ┌───────────────────────────────────────────────────────────┐
        # │ Arhives / Packages                                        │
        # └───────────────────────────────────────────────────────────┘
        ".7z" =             "01;38;5;61"; # Arhives / Packages
        ".WARC" =           "00;38;5;61"; # Arhives / Packages
        ".Z" =              "01;38;5;61"; # Arhives / Packages
        ".ZIP" =            "01;38;5;61"; # Arhives / Packages
        ".ace" =            "01;38;5;61"; # Arhives / Packages
        ".alp" =            "01;38;5;61"; # Arhives / Packages
        ".alz" =            "01;38;5;61"; # Arhives / Packages
        ".arc" =            "00;38;5;61"; # Arhives / Packages
        ".arj" =            "00;38;5;61"; # Arhives / Packages (legacy)
        ".br" =             "01;38;5;61"; # Arhives / Packages
        ".bz" =             "01;38;5;61"; # Arhives / Packages
        ".bz2" =            "01;38;5;61"; # Arhives / Packages
        ".cpio" =           "01;38;5;61"; # Arhives / Packages
        ".dz" =             "01;38;5;61"; # Arhives / Packages
        ".gz" =             "01;38;5;61"; # Arhives / Packages
        ".klwp" =           "00;38;5;61"; # Arhives / Packages
        ".lha" =            "01;38;5;61"; # Arhives / Packages
        ".lrz" =            "01;38;5;61"; # Arhives / Packages
        ".lz" =             "01;38;5;61"; # Arhives / Packages
        ".lz4" =            "01;38;5;61"; # Arhives / Packages
        ".lzh" =            "01;38;5;61"; # Arhives / Packages
        ".lzma" =           "01;38;5;61"; # Arhives / Packages
        ".lzo" =            "01;38;5;61"; # Arhives / Packages
        ".rar" =            "00;38;5;61"; # Arhives / Packages
        ".rz" =             "01;38;5;61"; # Arhives / Packages
        ".s7z" =            "01;38;5;61"; # Arhives / Packages
        ".t7z" =            "01;38;5;61"; # Arhives / Packages
        ".tar" =            "00;38;5;61"; # Arhives / Packages
        ".taz" =            "01;38;5;61"; # Arhives / Packages
        ".tbz" =            "01;38;5;61"; # Arhives / Packages
        ".tbz2" =           "01;38;5;61"; # Arhives / Packages
        ".tgz" =            "01;38;5;61"; # Arhives / Packages
        ".tlz" =            "01;38;5;61"; # Arhives / Packages
        ".txz" =            "01;38;5;61"; # Arhives / Packages
        ".tz" =             "01;38;5;61"; # Arhives / Packages
        ".tzo" =            "01;38;5;61"; # Arhives / Packages
        ".warc" =           "00;38;5;61"; # Arhives / Packages
        ".xz" =             "01;38;5;61"; # Arhives / Packages
        ".z" =              "01;38;5;61"; # Arhives / Packages
        ".zip" =            "01;38;5;61"; # Arhives / Packages
        ".zipx" =           "01;38;5;61"; # Arhives / Packages
        ".zoo" =            "01;38;5;61"; # Arhives / Packages
        ".zpaq" =           "01;38;5;61"; # Arhives / Packages
        ".zst" =            "01;38;5;61"; # Arhives / Packages
        ".zstd" =           "01;38;5;61"; # Arhives / Packages
        ".zz" =             "01;38;5;61"; # Arhives / Packages
        # ┌───────────────────────────────────────────────────────────┐
        # │ Archive temporarypart                                     │
        # └───────────────────────────────────────────────────────────┘
        ".part" =           "01;38;5;244"; # Archive temporarypart
        ".r[0-9]{0,2}" =    "01;38;5;244"; # Archive temporarypart
        ".z[0-9]{0,2}" =    "01;38;5;244"; # Archive temporarypart
        ".zx[0-9]{0,2}" =   "01;38;5;244"; # Archive temporarypart
        # ┌───────────────────────────────────────────────────────────┐
        # │ Packaged apps                                             │
        # └───────────────────────────────────────────────────────────┘
        ".apk" =            "00;38;5;74"; # Packaged apps
        ".bsp" =            "00;38;5;74"; # Packaged apps (valve bsp)
        ".cab" =            "00;38;5;74"; # Packaged apps
        ".crx" =            "04;38;5;74"; # Packaged apps # Google Chrome extension
        ".deb" =            "00;38;5;74"; # Packaged apps
        ".ear" =            "00;38;5;73"; # Packaged apps
        ".egg" =            "00;38;5;74"; # Packaged apps
        ".gem" =            "00;38;5;74"; # Packaged apps
        ".jad" =            "00;38;5;74"; # Packaged apps
        ".jar" =            "00;38;5;73"; # Packaged apps
        ".msi" =            "00;38;5;74"; # Packaged apps
        ".pak" =            "00;38;5;74"; # Packaged apps
        ".pk3" =            "00;38;5;74"; # Packaged apps (quake)
        ".pkg" =            "00;38;5;74"; # Packaged apps (quake)
        ".rpm" =            "00;38;5;74"; # Packaged apps
        ".sar" =            "00;38;5;73"; # Packaged apps
        ".udeb" =           "00;38;5;74"; # Packaged apps
        ".vdf" =            "00;38;5;74"; # Packaged apps (valve data file)
        ".vpk" =            "00;38;5;74"; # Packaged apps (valve data file)
        ".war" =            "00;38;5;73"; # Packaged apps
        ".xpi" =            "04;38;5;74"; # Packaged apps # Mozilla Firefox extension
        # ┌───────────────────────────────────────────────────────────┐
        # │ Disk images                                               │
        # └───────────────────────────────────────────────────────────┘
        ".fvd" =            "00;38;5;89"; # Disk images (virtual, QEMU)
        ".qcow" =           "00;38;5;89"; # Disk images (virtual, QEMU)
        ".qcow2" =          "00;38;5;89"; # Disk images (virtual, QEMU)
        ".vdi" =            "00;38;5;89"; # Disk images (virtual)
        ".vhd" =            "00;38;5;89"; # Disk images (virtual, old)
        ".vhdx" =           "00;38;5;89"; # Disk images (virtual, hyper-v)
        ".vmdk" =           "00;38;5;89"; # Disk images (virtual)
        # ┌───────────────────────────────────────────────────────────┐
        # │ Binary files (or domains lol)                             │
        # └───────────────────────────────────────────────────────────┘
        ".bin" =            "00;38;5;249"; # Binary data
        ".com" =            "00;38;5;111"; # MS Executable
        ".ru"  =            "00;38;5;111"; # MS Executable
        ".net" =            "00;38;5;111"; # MS Executable
        ".exe" =            "00;38;5;111"; # MS Executable
        ".lnk" =            "00;38;5;39"; # Windows symlink
        # ┌───────────────────────────────────────────────────────────┐
        # │ Disk images                                               │
        # └───────────────────────────────────────────────────────────┘
        ".dmg" =            "01;38;5;134"; # Disk images (apple)
        ".img" =            "01;38;5;134"; # Disk images
        ".ipa" =            "01;38;5;134"; # Ipad archive
        ".iso" =            "01;38;5;134"; # Disk images (cd / dvd)
        ".ISO" =            "01;38;5;134"; # Disk images (cd / dvd)
        ".mdf" =            "01;38;5;134"; # Disk images (cd / dvd)
        ".nrg" =            "01;38;5;134"; # Disk images
        ".sparseimage" =    "01;38;5;134"; # Disk images (apple)
        ".toast" =          "01;38;5;134"; # Disk images (cd / dvd)
        ".vcd" =            "01;38;5;134"; # Disk images (video cd)
        ".vfd" =            "01;38;5;134"; # Disk images (floppy)
        # ┌───────────────────────────────────────────────────────────┐
        # │ Graphics                                                  │
        # └───────────────────────────────────────────────────────────┘
        ".bpg" =            "01;38;5;24"; # Graphics
        ".cgm" =            "01;38;5;24"; # Graphics
        ".CR2" =            "01;38;5;24"; # Graphics
        ".dl" =             "00;38;5;24"; # Graphics
        ".emf" =            "01;38;5;24"; # Graphics
        ".jpeg" =           "00;38;5;24"; # Graphics
        ".jpg" =            "00;38;5;24"; # Graphics
        ".JPG" =            "00;38;5;24"; # Graphics
        ".jxl" =            "01;38;5;24"; # Graphics (jpeg xl)
        ".mng" =            "00;38;5;24"; # Graphics
        ".pcx" =            "00;38;5;24"; # Graphics
        ".png" =            "01;38;5;24"; # Graphics
        ".psd" =            "01;38;5;24"; # Graphics (photoshop)
        ".pxd" =            "01;38;5;24"; # Graphics (pixelmator pro)
        ".pxm" =            "01;38;5;24"; # Graphics (pixelmator image)
        ".webp" =           "01;38;5;24"; # Graphics
        ".xcf" =            "01;38;5;24"; # Graphics
        ".xwd" =            "01;38;5;24"; # Graphics
        ".yuv" =            "01;38;5;24"; # Graphics
        ".bmp" =            "01;38;5;110"; # Bitmap
        ".cdr" =            "00;38;5;110"; # Graphics (unusual)
        ".dicom" =          "00;38;5;110"; # Graphics (unusual)
        ".flif" =           "00;38;5;110"; # Graphics (unusual)
        ".indd" =           "00;38;5;110"; # Bitmap
        ".nth" =            "00;38;5;110"; # Graphics (unusual)
        ".pbm" =            "00;38;5;110"; # Bitmap
        ".pgm" =            "00;38;5;110"; # Bitmap
        ".ppm" =            "00;38;5;110"; # Bitmap
        ".tga" =            "00;38;5;110"; # Bitmap
        ".xbm" =            "00;38;5;111"; # Bitmap
        ".xpm" =            "00;38;5;110"; # Bitmap
        ".tif" =            "00;38;5;33"; # Big picture format
        ".tiff" =           "00;38;5;33"; # Big picture format
        ".TIFF" =           "00;38;5;33"; # Big picture format
        ".gif" =            "01;38;5;25"; # Images, animated
        ".icns" =           "01;38;5;25"; # Icons
        ".ico" =            "01;38;5;25"; # Icons
        # ┌───────────────────────────────────────────────────────────┐
        # │ Vector images                                             │
        # └───────────────────────────────────────────────────────────┘
        ".ai" =             "00;38;5;25"; # Vector images
        ".drw" =            "00;38;5;25"; # Vector images
        ".eps" =            "00;38;5;25"; # Vector images
        ".eps2" =           "00;38;5;25"; # Vector images
        ".eps3" =           "00;38;5;25"; # Vector images
        ".epsf" =           "00;38;5;25"; # Vector images
        ".epsi" =           "00;38;5;25"; # Vector images
        ".ps" =             "00;38;5;25"; # Vector images
        ".svg" =            "00;38;5;25"; # Vector images
        ".svgz" =           "00;38;5;25"; # Vector images
         # ┌───────────────────────────────────────────────────────────┐
         # │ Color profiles                                            │
         # └───────────────────────────────────────────────────────────┘
        ".icc" =            "00;38;5;249"; # Color profiles
        ".icm" =            "00;38;5;249"; # Color profiles
        # ┌───────────────────────────────────────────────────────────┐
        # │ Encrypted data                                            │
        # └───────────────────────────────────────────────────────────┘
        ".asc" =            "01;38;5;74";  # Encrypted data
        ".bfe" =            "00;38;5;74";  # Encrypted data
        ".enc" =            "00;38;5;74";  # Encrypted data
        ".ffp" =            "00;38;5;74";  # Encrypted data
        ".gpg" =            "00;38;5;74";  # Encrypted data
        ".key" =            "01;38;5;74";  # Encrypted data
        ".md5" =            "00;38;5;74";  # Encrypted data
        ".p12" =            "00;38;5;74";  # Encrypted data
        ".p7s" =            "00;38;5;74";  # Encrypted data
        ".par" =            "00;38;5;74";  # Encrypted data
        ".pem" =            "00;38;5;74";  # Encrypted data
        ".pgp" =            "00;38;5;74";  # Encrypted data
        ".pub" =            "00;38;5;74";  # Encrypted data
        ".sfv" =            "00;38;5;74";  # Encrypted data
        ".sha1" =           "00;38;5;74";  # Encrypted data
        ".sig" =            "00;38;5;74";  # Encrypted data
        ".signature" =      "00;38;5;74";  # Encrypted data
        ".st5" =            "00;38;5;74";  # Encrypted data
        "*id_dsa" =         "00;38;5;74";  # Encrypted data
        "*id_ecdsa" =       "00;38;5;74";  # Encrypted data
        "*id_ed25519" =     "00;38;5;74";  # Encrypted data
        "*id_rsa" =         "00;38;5;74";  # Encrypted data
        # ┌───────────────────────────────────────────────────────────┐
        # │ Error                                                     │
        # └───────────────────────────────────────────────────────────┘
        ".err" =            "01;04;38;5;160"; # error logs
        ".error" =          "01;04;38;5;160"; # error logs
        ".mdump" =          "01;04;38;5;160"; # Mini DuMP crash report
        ".stderr" =         "01;04;38;5;160"; # error logs
        "*core" =           "38;5;196;48;5;52"; # Linux user core dump file (from /proc/sys/kernel/core_pattern)
        # ┌───────────────────────────────────────────────────────────┐
        # │ Documents (binary)                                        │
        # └───────────────────────────────────────────────────────────┘
        ".cbr" =            "01;38;5;15"; # Documents (binary) (comix archive)
        ".cbz" =            "01;38;5;15"; # Documents (binary)
        ".chm" =            "01;38;5;15"; # Documents (binary)
        ".epub" =           "00;38;5;15"; # Documents (binary)
        ".fb2" =            "00;38;5;15"; # Documents (binary)
        ".lit" =            "00;38;5;15"; # Documents (binary)
        ".mobi" =           "00;38;5;15"; # Documents (binary)
        ".pdf" =            "01;38;5;15"; # Documents (binary)
        ".PDF" =            "01;38;5;15"; # Documents (binary)
        ".djv" =            "00;38;5;249"; # Documents (djvu)
        ".djvu" =           "00;38;5;249"; # Documents (djvu)
        ".dvi" =            "01;38;5;249"; # Documents (djvu)
        ".doc" =            "00;38;5;1"; # Documents with macros (office)
        ".docm" =           "00;38;5;1"; # Documents (office)
        ".docx" =           "00;38;5;1"; # Documents (office)
        ".dot" =            "00;38;5;1"; # Documents (office)
        ".dotm" =           "00;38;5;1"; # Documents (office)
        ".odb" =            "00;38;5;1"; # Documents (office)
        ".odm" =            "00;38;5;1"; # Documents (office)
        ".odt" =            "00;38;5;1"; # Documents (office)
        ".pages" =          "00;38;5;1"; # Documents (office)
        ".chrt" =           "01;38;5;14"; # KOffice chart
        ".numbers" =        "00;38;5;14"; # Spreadsheet
        ".ods" =            "00;38;5;14"; # Spreadsheet
        ".xla" =            "00;38;5;14"; # Spreadsheet
        ".xls" =            "00;38;5;14"; # Spreadsheet
        ".xlsm" =           "00;38;5;14"; # Spreadsheet
        ".xlsx" =           "04;38;5;14"; # Spreadsheet
        ".xltm" =           "04;38;5;14"; # Spreadsheet (with macros)
        ".xltx" =           "04;38;5;14"; # Spreadsheet (with macros)
        ".odp" =            "00;38;5;31"; # Presentation
        ".pps" =            "00;38;5;31"; # Presentation
        ".ppt" =            "00;38;5;31"; # Presentation (with macros)
        ".ppts" =           "00;38;5;31"; # Presentation
        ".pptx" =           "00;38;5;31"; # Presentation (with macros)
        ".pptsm" =          "00;38;5;31;4"; # Presentation (with macros)
        ".pptxm" =          "00;38;5;31;4"; # Presentation (with macros)
        # ┌───────────────────────────────────────────────────────────┐
        # │ Data store                                                │
        # └───────────────────────────────────────────────────────────┘
        ".btm" =            "00;38;5;99"; # Data store
        ".db" =             "00;38;5;99"; # Data store
        ".fmp12" =          "00;38;5;99"; # Data store
        ".fp7" =            "00;38;5;99"; # Data store
        ".ldf" =            "00;38;5;99"; # MS SQL journal
        ".localstorage" =   "00;38;5;99"; # Data store
        ".mdb" =            "00;38;5;99"; # Data store
        ".mde" =            "00;38;5;99"; # Data store
        ".nc" =             "00;38;5;99"; # Data store # NetCDF
        ".sqlite" =         "00;38;5;99"; # Data store
        ".typelib" =        "00;38;5;99"; # Data store
        ".accdb" =          "00;38;5;161"; # Data store # MS Access
        ".accde" =          "00;38;5;161"; # Data store # MS Access
        ".accdr" =          "00;38;5;161"; # Data store # MS Access
        ".accdt" =          "00;38;5;161"; # Data store # MS Access
        # ┌───────────────────────────────────────────────────────────┐
        # │ Markup                                                    │
        # └───────────────────────────────────────────────────────────┘
        ".adoc" =           "00;38;5;246"; # Markup
        ".asciidoc" =       "00;38;5;246"; # Markup
        ".etx" =            "00;38;5;246"; # Markup
        ".markdown" =       "00;38;5;246"; # Markup
        ".md" =             "00;38;5;246"; # Markup
        ".mdx" =            "00;38;5;246"; # Markup (markdown with jsx)
        ".mkd" =            "00;38;5;246"; # Markup
        ".pod" =            "00;38;5;246"; # Markup
        ".rst" =            "00;38;5;246"; # Markup
        ".wiki" =           "00;38;5;246"; # Markup
        ".info" =           "03;38;5;249"; # Markup (alternative)
        ".latex" =          "03;38;5;249"; # Markup (alternative)
        ".norg" =           "03;38;5;249"; # Markup (alternative)
        ".org" =            "03;38;5;249"; # Markup (alternative)
        ".tex" =            "03;38;5;249"; # Markup (alternative)
        ".textile" =        "03;38;5;249"; # Markup (alternative)
        "*1" =              "03;38;5;249"; # Markup (alternative)
        # ┌───────────────────────────────────────────────────────────┐
        # │ Shell                                                     │
        # └───────────────────────────────────────────────────────────┘
        ".awk" =            "00;38;5;103"; # UNIX Shell
        ".bash" =           "01;38;5;103"; # UNIX Shell
        ".bash_history" =   "01;38;5;103"; # UNIX Shell
        ".bash_login" =     "03;38;5;103"; # UNIX Shell
        ".bash_logout" =    "03;38;5;103"; # UNIX Shell
        ".bash_profile" =   "03;38;5;103"; # UNIX Shell
        ".csh" =            "01;38;5;103"; # UNIX Shell
        ".dash" =           "01;38;5;103"; # UNIX Shell
        ".fish" =           "01;38;5;103"; # UNIX Shell
        ".ksh" =            "01;38;5;103"; # UNIX Shell
        ".profile" =        "03;38;5;103"; # UNIX Shell
        ".sed" =            "03;38;5;103"; # UNIX Shell
        ".zlogin" =         "03;38;5;103"; # UNIX Shell
        ".zlogout" =        "03;38;5;103"; # UNIX Shell
        ".zprofile" =       "03;38;5;103"; # UNIX Shell
        ".zshenv" =         "03;38;5;103"; # UNIX Shell
        "bashrc" =          "03;38;5;103"; # UNIX Shell
        ".sh" =             "01;38;5;103"; # UNIX Shell
        ".sh*" =            "01;38;5;103"; # UNIX Shell
        ".tcsh" =           "01;38;5;103"; # UNIX Shell
        ".zsh" =            "01;38;5;103"; # UNIX Shell
        "zshrc" =           "03;38;5;103"; # UNIX Shell
        ".zwc" =            "00;38;5;244"; # UNIX Shell
        ".bat" =            "00;38;5;31"; # MS Shell
        ".cmd" =            "00;38;5;31"; # MS Shell
        # ┌───────────────────────────────────────────────────────────┐
        # │ Web stuff                                                 │
        # └───────────────────────────────────────────────────────────┘
        ".astro" =          "01;38;5;250"; # Web templates
        ".ejs" =            "01;38;5;250"; # Web templates
        ".mustache" =       "01;38;5;250"; # Web templates
        ".pug" =            "01;38;5;250"; # Web templates
        ".svelte" =         "01;38;5;250"; # Web templates
        ".vue" =            "01;38;5;250"; # Web templates
        ".css" =            "00;38;5;31"; # Web styles
        ".less" =           "00;38;5;31"; # Web styles
        ".sass" =           "00;38;5;31"; # Web styles
        ".scss" =           "00;38;5;31"; # Web styles
        ".htm" =            "00;38;5;29"; # Web markup
        ".html" =           "00;38;5;29"; # Web markup
        ".jhtm" =           "00;38;5;29"; # Web markup
        ".mht" =            "00;38;5;29"; # Web markup
        # ┌───────────────────────────────────────────────────────────┐
        # │ Diff / patch                                              │
        # └───────────────────────────────────────────────────────────┘
        ".diff" =           "48;5;7;38;5;16;1"; # diff file
        ".patch" =          "48;5;7;38;5;16;1"; # patch file
        # ┌───────────────────────────────────────────────────────────┐
        # │ Theme                                                     │
        # └───────────────────────────────────────────────────────────┘
        ".attheme" =        "01;38;5;5"; # Theme (android telegram theme data)
        ".colors" =         "01;38;5;5"; # Theme
        ".rasi" =           "01;38;5;5"; # Theme
        ".sty" =            "01;38;5;5"; # Theme
        ".sug" =            "01;38;5;5"; # Theme
        ".tdesktop-pallete"="01;38;5;5"; # Theme
        ".tdesktop-theme" = "01;38;5;5"; # Theme
        ".tdy" =            "01;38;5;5"; # Theme
        ".tfm" =            "01;38;5;5"; # Theme
        ".tfnt" =           "01;38;5;5"; # Theme
        ".theme" =          "01;38;5;5"; # Theme
        # ┌───────────────────────────────────────────────────────────┐
        # │ /etc/hosts.{deny,allow}                                   │
        # └───────────────────────────────────────────────────────────┘
        ".allow" =          "00;38;5;24";
        ".deny" =           "00;38;5;89";
        # ┌───────────────────────────────────────────────────────────┐
        # │ Files of special interest                                 │
        # └───────────────────────────────────────────────────────────┘
        ".icls" =           "00;38;5;60";
        ".jidgo" =          "00;38;5;60";
        ".modulemap" =      "00;38;5;60";
        ".n3" =             "00;38;5;60";
        ".nt" =             "00;38;5;60";
        ".owl" =            "00;38;5;60";
        ".qml" =            "00;38;5;60";
        ".rdf" =            "00;38;5;60";
        ".torrent" =        "00;38;5;60";
        ".ttl" =            "00;38;5;60";
        # ┌───────────────────────────────────────────────────────────┐
        # │ Build                                                     │
        # └───────────────────────────────────────────────────────────┘
        ".dhall" =          "00;38;5;29"; # Functional configuration
        ".mk" =             "00;38;5;60"; # Build files
        ".rake" =           "00;38;5;60"; # Build process (Ruby)
        ".sbt" =            "00;38;5;60"; # Build files
        "*Dockerfile" =     "00;38;5;60"; # Build files
        "*Makefile" =       "00;38;5;60"; # Build files
        "*Containerfile" =  "00;38;5;60"; # Build process # Containers
        "*Rakefile" =       "00;38;5;60"; # Build files
        "*build.xml" =      "00;38;5;60"; # Build files
        "*MANIFEST" =       "00;38;5;243"; # Build process (Make)
        "*pm_to_blib" =     "00;38;5;250"; # Build process (Perl)
        # ┌───────────────────────────────────────────────────────────┐
        # │ Config                                                    │
        # └───────────────────────────────────────────────────────────┘
        "*authorized_keys" = "03;38;5;2"; # Config
        ".cfg" =           "00;38;5;2"; # Config
        "*cfg" =           "03;38;5;2"; # Config
        ".conf" =          "00;38;5;2"; # Config
        "*conf" =          "03;38;5;2"; # Config
        "*config" =        "03;38;5;2"; # Config
        ".hgignore" =      "03;38;5;2"; # Config
        ".hgrc" =          "00;38;5;2"; # Config
        ".htoprc" =        "00;38;5;2"; # Config
        ".ini" =           "00;38;5;2"; # Config
        ".json" =          "00;38;5;2"; # Config
        "*known_hosts" =   "03;38;5;2"; # Config
        ".msmtprc" =       "00;38;5;2"; # Config
        ".muttrc" =        "00;38;5;33"; # Config unusual
        ".netrc" =         "03;38;5;33"; # Config
        ".nix" =           "00;38;5;29"; # Config functional
        ".ovpn" =          "03;38;5;33"; # Config unusual
        ".pacnew" =        "04;38;5;33"; # Config unusual
        ".prisma" =        "04;38;5;33"; # Prisma Schema/Config
        ".psf" =           "03;38;5;2"; # Config (photoshop settings)
        "*rc" =            "03;38;5;2"; # Config
        ".rc" =            "03;38;5;2"; # Config
        ".reg" =           "04;38;5;33"; # Config unusual
        ".sls" =           "03;38;5;2"; # Config (yaml usually)
        ".xkb" =           "03;38;5;2"; # Config
        # ┌───────────────────────────────────────────────────────────┐
        # │ X11 config files                                          │
        # └───────────────────────────────────────────────────────────┘
        ".Xauthority" =    "01;38;5;4"; # X11 config files
        ".xinitrc" =       "01;38;5;4"; # X11 config files
        ".Xmodmap" =       "00;38;5;4"; # X11 config files
        ".Xresources" =    "01;38;5;33"; # X11 config files
        # ┌───────────────────────────────────────────────────────────┐
        # │ Vim and friends                                           │
        # └───────────────────────────────────────────────────────────┘
        ".kak" =           "00;38;5;56"; # Kakoine
        ".vim" =           "00;38;5;56"; # Vim (legacy)
        ".viminfo" =       "00;38;5;56"; # Vim (legacy)
        ".vimp" =          "00;38;5;56"; # Vim (legacy)
        ".vimrc" =         "04;38;5;56"; # Vim (legacy)
        ".snippets" =      "00;38;5;31"; # Vim snippets
        # ┌───────────────────────────────────────────────────────────┐
        # │ Data store ( non-relational )                             │
        # └───────────────────────────────────────────────────────────┘
        ".bib" =           "00;38;5;29"; # Data store # non-relational
        ".dtd" =           "00;38;5;29"; # Data store # non-relational
        ".epf" =           "00;38;5;29"; # Data store # non-relational # Autodesk preferences
        ".fxml" =          "00;38;5;29"; # Data store # non-relational
        ".hjson" =         "01;38;5;29"; # Data store # non-relational
        ".json5" =         "00;38;5;29"; # Data store # non-relational
        ".jsonc" =         "00;38;5;29"; # Data store # non-relational
        ".jsonl" =         "00;38;5;29"; # Data store # non-relational
        ".jsonnet" =       "00;38;5;29"; # Data store # non-relational
        ".libsonnet" =     "00;38;5;29"; # Data store # non-relational
        ".msg" =           "00;38;5;29"; # Data store # non-relational
        ".ndjson" =        "00;38;5;29"; # Data store # non-relational
        ".pgn" =           "00;38;5;29"; # Data store # non-relational
        ".plist" =         "00;38;5;29"; # Data store # non-relational (apple property list)
        ".rdata" =         "00;38;5;29"; # Data store # non-relational
        ".RData" =         "00;38;5;29"; # Data store # non-relational
        ".rnc" =           "00;38;5;29"; # Data store # non-relational
        ".rng" =           "00;38;5;29"; # Data store # non-relational
        ".rss" =           "00;38;5;29"; # Data store # non-relational
        ".sgml" =          "00;38;5;29"; # Data store # non-relational
        ".tmTheme" =       "00;38;5;29"; # Data store # non-relational # Textmate settings
        ".toml" =          "00;38;5;29"; # Data store # non-relational
        ".xml" =           "00;38;5;29"; # Data store # non-relational
        ".xsd" =           "00;38;5;29"; # Data store # non-relational
        ".yaml" =          "00;38;5;29"; # Data store # non-relational
        ".yml" =           "00;38;5;29"; # Data store # non-relational
        # ┌───────────────────────────────────────────────────────────┐
        # │ Spreadsheet (plain text)                                  │
        # └───────────────────────────────────────────────────────────┘
        ".csv" =            "00;38;5;28"; # Spreadsheet (plain text)
        ".tsv" =            "00;38;5;28"; # Spreadsheet (plain text)
        # ┌───────────────────────────────────────────────────────────┐
        # │ Libraries                                                 │
        # └───────────────────────────────────────────────────────────┘
        ".a" =              "01;38;5;22"; # Libraries
        ".dll" =            "01;38;5;22"; # Libraries
        ".o" =              "01;38;5;236"; # *nix Object file (shared libraries, core dumps etc)
        ".rlib" =           "01;38;5;236"; # Static rust library
        ".so" =             "01;38;5;22"; # Libraries
        # ┌───────────────────────────────────────────────────────────┐
        # │ Audio formats (lossy)                                     │
        # └───────────────────────────────────────────────────────────┘
        ".aac" =            "03;38;5;37"; # Audio formats (lossy, Apple)
        ".axa" =            "03;38;5;37"; # Audio formats (lossy, CSIRO)
        ".m4a" =            "03;38;5;37"; # Audio formats (lossy, container, aac usually)
        ".m4b" =            "03;38;5;37"; # Audio formats (lossy, audiobook)
        ".m4r" =            "03;38;5;37"; # Audio formats (lossy, container, aac usually)
        ".mka" =            "03;38;5;37"; # Audio formats (lossy, matroska audio container)
        ".mp2" =            "03;38;5;37"; # Audio formats (lossy)
        ".mp3" =            "03;38;5;37"; # Audio formats (lossy)
        ".mp4a"=            "03;38;5;37"; # Audio (lossy)
        ".mpc" =            "03;38;5;37"; # Audio formats (lossy, musepack)
        ".oga" =            "03;38;5;37"; # Audio formats (lossy)
        ".ogg" =            "03;38;5;37"; # Audio formats (lossy)
        ".opus" =           "03;38;5;37"; # Audio (lossy)
        ".ra" =             "03;38;5;37"; # Audio formats (lossy, real audio)
        ".spx" =            "03;38;5;37"; # Audio formats (lossy, compressed ogg)
        ".wma" =            "03;38;5;37"; # Audio formats (lossy)
         # ┌───────────────────────────────────────────────────────────┐
         # │ Audio formats (lossless)                                  │
         # └───────────────────────────────────────────────────────────┘
        ".alac" =           "01;03;38;5;34"; # Audio formats (lossless, Apple)
        ".ape" =            "01;03;38;5;34"; # Audio formats (lossless)
        ".cda" =            "01;38;5;34"; # Audio (lossless)
        ".flac" =           "01;03;38;5;34"; # Audio formats (lossless)
        ".pcm" =            "01;38;5;34"; # Audio (lossless)
        ".wav" =            "01;03;38;5;34"; # Audio formats (lossy)
        # ┌───────────────────────────────────────────────────────────┐
        # │ Audio formats (dsd)                                       │
        # └───────────────────────────────────────────────────────────┘
        ".dff" =            "01;03;38;5;36"; # Audio formats (dsd)
        ".dsf" =            "01;03;38;5;36"; # Audio formats (dsd)
        # ┌───────────────────────────────────────────────────────────┐
        # │ Audio formats (midi)                                      │
        # └───────────────────────────────────────────────────────────┘
        ".mid" =            "04;38;5;37"; # Audio formats (midi)
        ".midi" =           "04;38;5;37"; # Audio formats (midi)
        # ┌───────────────────────────────────────────────────────────┐
        # │ Another audio formats                                     │
        # └───────────────────────────────────────────────────────────┘
        ".3ga" =            "00;38;5;5"; # Another audio formats
        ".aiff" =           "00;38;5;5"; # Another audio formats (Apple legacy)
        ".amr" =            "00;38;5;5"; # Another audio formats
        ".au" =             "00;38;5;5"; # Another audio formats (lossy, Sun legacy)
        ".caf" =            "00;38;5;5"; # Another audio formats
        ".dat" =            "00;38;5;5"; # Another audio formats
        ".dts" =            "00;38;5;5"; # Another audio formats
        ".fcm" =            "00;38;5;5"; # Another audio formats
        ".mod" =            "00;38;5;5"; # Another audio formats
        ".s3m" =            "01;38;5;5"; # Another audio formats
        ".S3M" =            "01;38;5;5"; # Another audio formats
        ".sid" =            "01;38;5;5"; # Another audio formats
        ".spl" =            "00;38;5;5"; # Another audio formats
        ".wv" =             "00;38;5;5"; # Another audio formats
        ".wvc" =            "00;38;5;5"; # Another audio formats
        # ┌───────────────────────────────────────────────────────────┐
        # │ Metainformation                                           │
        # └───────────────────────────────────────────────────────────┘
        ".IFO" =            "00;38;5;28"; # Video metainformation
        ".cue" =            "03;38;5;28"; # Audio metainformation
        ".m3u" =            "03;38;5;28"; # Sheets
        ".m3u8" =           "03;38;5;28"; # Sheets
        ".pls" =            "03;38;5;28"; # Sheets
        ".xspf" =           "03;38;5;28"; # Sheets
        # ┌───────────────────────────────────────────────────────────┐
        # │ Video                                                     │
        # └───────────────────────────────────────────────────────────┘
        ".avi" =           "01;38;5;75"; # Video
        ".AVI" =           "01;38;5;75"; # Video
        ".divx" =          "01;38;5;75"; # Video
        ".flc" =           "01;38;5;75"; # Video
        ".fli" =           "01;38;5;75"; # Video
        ".gl" =            "01;38;5;75"; # Video
        ".m2ts" =          "01;38;5;75"; # Video
        ".m2v" =           "01;38;5;75"; # Video
        ".m4v" =           "01;38;5;75"; # Video
        ".mjpeg" =         "01;38;5;75"; # Video
        ".mkv" =           "01;38;5;75"; # Video
        ".mov" =           "01;38;5;75"; # Video
        ".MOV" =           "01;38;5;75"; # Video
        ".mp4" =           "01;38;5;75"; # Video
        ".mp4v" =          "01;38;5;75"; # Video
        ".mpeg" =          "01;38;5;75"; # Video
        ".mpg" =           "01;38;5;75"; # Video
        ".nuv" =           "01;38;5;75"; # Video
        ".ogm" =           "01;38;5;75"; # Video
        ".qt" =            "01;38;5;75"; # Video
        ".rm" =            "01;38;5;75"; # Video
        ".rmvb" =          "01;38;5;75"; # Video
        ".sample" =        "01;38;5;75"; # Video
        ".vob" =           "01;38;5;75"; # Video (lossless)
        ".VOB" =           "01;38;5;75"; # Video (lossless)
        ".wmv" =           "00;38;5;75"; # Video
        # ┌───────────────────────────────────────────────────────────┐
        # │ Video (mobile/streaming)                                  │
        # └───────────────────────────────────────────────────────────┘
        ".3g2" =           "03;38;5;75"; # Video (mobile/streaming)
        ".3gp" =           "03;38;5;75"; # Video (mobile/streaming)
        ".asf" =           "03;38;5;75"; # Video (mobile/streaming)
        ".f4v" =           "03;38;5;75"; # Video (mobile/streaming)
        ".flv" =           "03;38;5;75"; # Video (mobile/streaming)
        ".gp3" =           "03;38;5;75"; # Video (mobile/streaming)
        ".gp4" =           "03;38;5;75"; # Video (mobile/streaming)
        ".ogv" =           "03;38;5;75"; # Video (mobile/streaming)
        ".webm" =          "03;38;5;75"; # Video (mobile/streaming)
        # ┌───────────────────────────────────────────────────────────┐
        # │ Deprecated media                                          │
        # └───────────────────────────────────────────────────────────┘
        # http://wiki.xiph.org/index.php/MIME_Types_and_File_Extensions
        ".anx" =            "01;38;5;13";
        ".axv" =            "01;38;5;13";
        ".ogx" =            "01;38;5;13";
        # ┌───────────────────────────────────────────────────────────┐
        # │ Subtitles                                                 │
        # └───────────────────────────────────────────────────────────┘
        ".ass" =            "01;38;5;116"; # Subtitles
        ".srt" =            "01;38;5;116"; # Subtitles
        ".ssa" =            "01;38;5;116"; # Subtitles
        ".sub" =            "01;38;5;116"; # Subtitles
        ".sup" =            "01;38;5;116"; # Subtitles
        ".vtt" =            "01;38;5;116"; # Subtitles
        # ┌───────────────────────────────────────────────────────────┐
        # │ Fonts                                                     │
        # └───────────────────────────────────────────────────────────┘
        ".afm" =           "01;38;5;61"; # Fonts (Adobe metrics file)
        ".bdf" =           "00;38;5;61"; # Fonts
        ".dfont" =         "01;38;5;61"; # Fonts
        ".fnt" =           "01;38;5;61"; # Fonts (Windows legacy)
        ".fon" =           "01;38;5;61"; # Fonts
        ".gsf" =           "00;38;5;61"; # Fonts
        ".otf" =           "01;38;5;61"; # Fonts
        ".pcf" =           "00;38;5;61"; # Fonts
        ".pfa" =           "00;38;5;61"; # Fonts
        ".PFA" =           "00;38;5;61"; # Fonts
        ".pfb" =           "00;38;5;61"; # Fonts
        ".pfm" =           "01;38;5;61"; # Fonts (Printer Font Metrics)
        ".ttf" =           "01;38;5;61"; # Fonts
        ".woff" =          "01;38;5;61"; # Fonts
        ".woff2" =         "01;38;5;61"; # Fonts
        # ┌───────────────────────────────────────────────────────────┐
        # │ Emulator roms / savegames                                 │
        # └───────────────────────────────────────────────────────────┘
        ".32x" =           "00;38;5;232"; # Emulator roms / savegames
        ".A64" =           "00;38;5;232"; # Emulator roms / savegames
        ".a00" =           "00;38;5;232"; # Emulator roms / savegames
        ".a52" =           "00;38;5;232"; # Emulator roms / savegames
        ".a64" =           "00;38;5;232"; # Emulator roms / savegames
        ".a78" =           "00;38;5;232"; # Emulator roms / savegames
        ".adf" =           "00;38;5;232"; # Emulator roms / savegames
        ".atr" =           "00;38;5;232"; # Emulator roms / savegames
        ".cdi" =           "00;38;5;232"; # Emulator roms / savegames
        ".fm2" =           "00;38;5;232"; # Emulator roms / savegames
        ".gb" =            "00;38;5;232"; # Emulator roms / savegames (Nindendo)
        ".gba" =           "00;38;5;232"; # Emulator roms / savegames (Nindendo)
        ".gbc" =           "00;38;5;232"; # Emulator roms / savegames (Nindendo)
        ".gel" =           "00;38;5;232"; # Emulator roms / savegames (Nindendo)
        ".gg" =            "00;38;5;232"; # Emulator roms / savegames (Nindendo)
        ".ggl" =           "00;38;5;232"; # Emulator roms / savegames (Nindendo)
        ".j64" =           "00;38;5;232"; # Emulator roms / savegames (Nindendo)
        ".nds" =           "00;38;5;232"; # Emulator roms / savegames (Nintendo)
        ".nes" =           "00;38;5;232"; # Emulator roms / savegames (Nintendo NES)
        ".rom" =           "01;38;5;232"; # Emulator roms / savegames
        ".sav" =           "00;38;5;232"; # Emulator roms / savegames
        ".sms" =           "00;38;5;232"; # Emulator roms / savegames
        ".st" =            "00;38;5;232"; # Emulator roms / savegames
        ".ipk" =           "00;38;5;232"; # Emulator roms / savegames (Nintendo DS Packed Images)
        # ┌───────────────────────────────────────────────────────────┐
        # │ Systemd                                                   │
        # └───────────────────────────────────────────────────────────┘
        ".automount" =     "00;38;5;66";
        ".desktop" =       "00;38;5;75";
        ".device" =        "00;38;5;24";
        ".mount" =         "00;38;5;66";
        ".path" =          "00;38;5;66";
        "@.service" =      "00;38;5;45";
        ".service" =       "00;38;5;81";
        ".snapshot" =      "00;38;5;97";
        ".socket" =        "00;38;5;75";
        ".swap" =          "00;38;5;95";
        ".target" =        "00;38;5;73";
        ".timer" =         "00;38;5;111";
        # ┌───────────────────────────────────────────────────────────┐
        # │ State files                                               │
        # └───────────────────────────────────────────────────────────┘
        ".pid" =           "01;38;5;1"; # pid file
        ".state" =         "01;38;5;1"; # State files
        # ┌───────────────────────────────────────────────────────────┐
        # │ Code (source files)                                       │
        # └───────────────────────────────────────────────────────────┘
        ".agda" =          "00;38;5;34"; # Agda
        ".agdai" =         "00;38;5;34"; # Agda
        ".c++" =           "01;03;38;5;24"; # C++
        ".C" =             "01;03;38;5;24"; # C++
        ".c" =             "01;38;5;110"; # Pure C
        ".tcc" =           "01;38;5;110"; # Pure C
        ".M" =             "00;38;5;110"; # Objective C method file
        ".m" =             "00;38;5;110"; # Objective C method file
        ".cc" =            "01;03;38;5;24"; # C++
        ".clj" =           "03;38;5;64"; # Clojure
        ".cljc" =          "00;38;5;64"; # Clojure
        ".cljs" =          "00;38;5;64"; # Clojure
        ".cljw" =          "00;38;5;64"; # Clojure Gorilla notebook
        ".cp" =            "01;03;38;5;24"; # C++
        ".cpp" =           "01;03;38;5;24"; # C++
        ".cr" =            "00;38;5;81"; # Crystal
        ".cs" =            "00;38;5;81"; # C Sharp
        ".cxx" =           "01;03;38;5;24"; # C++
        ".erl" =           "03;38;5;70"; # Erlang
        ".f03" =           "03;38;5;245"; # Fortran
        ".F03" =           "03;38;5;245"; # Fortran
        ".f" =             "03;38;5;245"; # Fortran
        ".F" =             "03;38;5;245"; # Fortran
        ".f08" =           "03;38;5;245"; # Fortran
        ".F08" =           "03;38;5;245"; # Fortran
        ".f90" =           "03;38;5;245"; # Fortran
        ".F90" =           "03;38;5;245"; # Fortran
        ".f95" =           "03;38;5;245"; # Fortran
        ".F95" =           "03;38;5;245"; # Fortran
        ".fnl" =           "03;38;5;64"; # Fennel
        ".for" =           "03;38;5;245"; # Fortran
        ".ftn" =           "03;38;5;245"; # Fortran
        ".go" =            "03;38;5;70"; # Go
        ".lagda" =         "00;38;5;34"; # Agda
        ".lagda.md" =      "00;38;5;34"; # Agda
        ".lagda.rst" =     "00;38;5;34"; # Agda
        ".lagda.tex" =     "00;38;5;34"; # Agda
        ".ml" =            "03;38;5;70"; # ML
        ".pas" =           "03;38;5;73"; # Pascal
        ".ctp" =           "00;38;5;4"; # Code (interpreted) (PHP CakePHP)
        ".php" =           "00;38;5;4"; # Code (interpreted) (PHP)
        ".pl" =            "00;38;5;73"; # Code (interpreted) (Perl)
        ".PL" =            "01;38;5;73"; # Code (interpreted) (Perl)
        ".pm" =            "00;38;5;4"; # Code (interpreted) (Perl)
        ".py" =            "01;38;5;30"; # Code (interpreted) (Python)
        ".r" =             "00;38;5;28"; # R
        ".R" =             "00;38;5;28"; # R
        ".rb" =            "01;03;38;5;33"; # Code (interpreted) (Ruby)
        ".rs" =            "03;38;5;73"; # Rust
        ".sc" =            "03;38;5;70"; # Scala
        ".scala" =         "03;38;5;70"; # Scala
        ".t" =             "01;38;5;28"; # Perl stuff or turing language
        ".tcl" =           "03;38;5;34"; # Tcl
        ".tk" =            "03;38;5;34"; # Tk
        ".xsh" =           "00;03;38;5;33"; # Code (interpreted) (xonsh)
        ".scpt" =          "03;38;5;219"; # AppleScript
        ".swift" =         "03;38;5;219"; # Swift
        ".comp" =          "00;38;5;142"; # SPIR-V shaders
        ".frag" =          "00;38;5;142"; # SPIR-V shaders
        ".glsl" =          "03;38;5;70"; # GLSL Shaders
        ".spv" =           "00;38;5;136"; # SPIR-V compiled shaders
        ".vert" =          "00;38;5;142"; # SPIR-V shaders
        ".wgsl" =          "00;38;5;97"; # WGSL shaders
        ".vb" =            "00;38;5;81"; # VBA
        ".vba" =           "00;38;5;81"; # VBA
        ".vbs" =           "00;38;5;81"; # VBA
        ".cjs" =           "03;38;5;74"; # CommonJS
        ".coffee" =        "03;38;5;74"; # Javascript
        ".dart" =          "03;38;5;74"; # Dart
        ".js" =            "03;38;5;74"; # Javascript
        ".jsx" =           "03;38;5;74"; # Javascript eXtended
        ".mjs" =           "03;38;5;74"; # ECMAScript
        ".ts" =            "03;38;5;74"; # Typescript
        ".tsx" =           "03;38;5;74"; # Typescript eXtended
        ".gs" =            "03;38;5;74"; # Google apps script
        ".lua" =           "00;38;5;74"; # Code (interpreted) (Lua)
        ".moon" =          "00;38;5;74"; # Code (interpreted) (Moonscript)
        ".cl" =            "00;38;5;74"; # LISP
        ".el" =            "00;38;5;64"; # LISP (Emacs)
        ".elc" =           "00;38;5;64"; # LISP (Emacs)
        ".eln" =           "00;38;5;64"; # LISP (Emacs)
        ".lisp" =          "00;38;5;74"; # Lisp
        ".rkt" =           "00;38;5;74"; # LISP
        ".scm" =           "00;38;5;74"; # Scheme
        ".ahk" =           "00;03;38;5;33"; # Code (interpreted) (AutoHotKey)
        ".asm" =           "00;38;5;64"; # Assembler
        ".e" =             "01;38;5;245";
        ".erb" =           "01;38;5;33";
        ".fehbg" =         "00;38;5;36";
        ".fonts" =         "00;38;5;36";
        ".gemspec" =       "00;03;38;5;33"; # Code (interpreted) (ruby)
        ".gnumeric" =      "00;38;5;14";
        ".hi" =            "00;38;5;34"; # Haskell headers
        ".hs" =            "00;38;5;34"; # Haskell
        ".ipynb" =         "03;38;5;33"; # Code (interpreted) (Python)
        ".irb" =           "01;38;5;33";
        ".lhs" =           "03;38;5;34"; # Haskell (literate)
        ".mf" =            "03;38;5;110";
        ".nim" =           "00;38;5;64"; # Nim
        ".nimble" =        "00;38;5;64"; # Nim
        ".pc" =            "00;38;5;4";
        ".sx" =            "00;38;5;64"; # SimplexNumerica
        ".tf" =            "00;38;5;29"; # Code (Terraform)
        ".tfstate" =       "00;38;5;29"; # Code (Terraform)
        ".tfvars" =        "00;38;5;29"; # Code (Terraform)
        ".v" =             "00;38;5;64"; # V
        ".vala" =          "00;38;5;64"; # Vala
        ".vapi" =          "00;38;5;64"; # Vala
        ".zig" =           "00;38;5;64"; # Zig
        ".msql" =          "00;38;5;83"; # Code (SQL)
        ".mysql" =         "00;38;5;83"; # Code (SQL)
        ".pgsql" =         "00;38;5;83"; # Code (SQL)
        ".prql" =          "00;38;5;83"; # Code (SQL)
        ".sql" =           "00;38;5;83"; # Code (SQL)
        ".java" =          "03;38;5;245"; # Java
        ".jsm" =           "00;38;5;245"; # Java
        ".jnlp" =          "03;38;5;245"; # Java
        ".jsp" =           "00;38;5;245"; # Java
        # ┌───────────────────────────────────────────────────────────┐
        # │ 3D printing                                               │
        # └───────────────────────────────────────────────────────────┘
        ".stl" =            "00;38;5;216"; # 3D printing
        ".dwg" =            "00;38;5;216"; # 3D printing
        ".ply" =            "00;38;5;216"; # 3D printing
        ".wrl" =            "00;38;5;216"; # 3D printing
        # ┌───────────────────────────────────────────────────────────┐
        # │ Texas Instruments Calculator files                        │
        # └───────────────────────────────────────────────────────────┘
        ".8xp" =            "00;38;5;204"; # Texas Instruments Calculator files
        ".8eu" =            "00;38;5;204"; # Texas Instruments Calculator files
        ".82p" =            "00;38;5;204"; # Texas Instruments Calculator files
        ".83p" =            "00;38;5;204"; # Texas Instruments Calculator files
        ".8xe" =            "00;38;5;204"; # Texas Instruments Calculator files
        # ┌───────────────────────────────────────────────────────────┐
        # │ Headers                                                   │
        # └───────────────────────────────────────────────────────────┘
        ".h" =              "00;38;5;247"; # C header
        ".H" =              "00;38;5;247"; # C header
        ".h++" =            "00;38;5;247"; # C++ header
        ".hh" =             "00;38;5;247"; # C++ header
        ".hpp" =            "00;38;5;247"; # C++ header
        ".hxx" =            "00;38;5;247"; # C++ header
        ".s" =              "00;38;5;247"; # Pascal or asm
        ".S" =              "00;38;5;247"; # Pascal or asm
        # ┌───────────────────────────────────────────────────────────┐
        # │ Version control                                           │
        # └───────────────────────────────────────────────────────────┘
        ".git" =            "00;38;5;36"; # Version control
        ".gitattributes" =  "00;38;5;36"; # Version control
        ".github" =         "00;38;5;36"; # Version control
        ".gitignore" =      "00;38;5;240"; # Version control
        # ┌───────────────────────────────────────────────────────────┐
        # │ Build process                                             │
        # └───────────────────────────────────────────────────────────┘
        ".am" =             "00;38;5;235"; # Build process (Automake)
        ".hin" =            "00;38;5;235"; # Build process (Automake)
        ".in" =             "00;38;5;235"; # Build process (Automake)
        ".m4" =             "00;38;5;235"; # Build process (Automake)
        ".old" =            "00;38;5;235"; # Build process (Automake)
        ".out" =            "00;38;5;235"; # Build process (Automake)
        ".scan" =           "00;38;5;235"; # Build process (Automake)
        ".SKIP" =           "00;38;5;235"; # Build process (Automake)
        ".containerignore"= "00;38;5;240"; # Build process (Containers)
        ".dockerignore" =   "00;38;5;240"; # Build process (Docker)
        # ┌───────────────────────────────────────────────────────────┐
        # │ Dump                                                      │
        # └───────────────────────────────────────────────────────────┘
        ".aria2" =          "00;38;5;29"; # Dump
        ".cap" =            "00;38;5;29"; # Dump
        ".dmp" =            "00;38;5;29"; # Dump
        ".dump" =           "00;38;5;29"; # Dump
        ".pcap" =           "00;38;5;29"; # Dump
        ".stackdump" =      "00;38;5;29"; # Dump
        ".zcompdump" =      "00;38;5;29"; # Dump
        ".eml" =            "01;38;5;90"; # Email (Web)
        ".http" =           "01;38;5;90"; # Request (Web)
        ".ttytterrc" =      "01;38;5;5";
        ".urlview" =        "01;38;5;5";
        ".webloc" =         "01;38;5;5"; # URL-like stuff
        # ┌───────────────────────────────────────────────────────────┐
        # │ Scum                                                      │
        # └───────────────────────────────────────────────────────────┘
        "*#" =                  "00;38;5;236"; # Scum
        "*~" =                  "03;38;5;236"; # Undo file
        ".added" =              "00;38;5;236"; # Temporary torrent
        ".aux" =                "01;38;5;236"; # LaTeX helper
        ".bbl" =                "01;38;5;236"; # Scum
        ".blg" =                "01;38;5;236"; # Scum
        ".cache" =              "01;38;5;236"; # Scum
        ".car" =                "38;5;57";     # macOS asset catalog
        ".CFUserTextEncoding" = "00;38;5;236"; # macOS
        ".class" =              "01;38;5;236"; # Scum
        "*CodeResources" =      "00;38;5;236"; # macOS code signing apps
        ".DS_Store" =           "00;38;5;236"; # macOS
        ".dylib" =              "38;5;241";   # macOS shared lib
        ".entitlements" =       "1";          # Xcode files
        ".ex" =                 "00;38;5;236"; # Scum
        ".example" =            "00;38;5;236"; # Scum
        ".feature" =            "00;38;5;236"; # Scum
        ".ics" =                "00;38;5;236"; # calendar information
        ".incomplete" =         "01;38;5;236"; # Scum
        ".localized" =          "00;38;5;236"; # macOS
        ".mfasl" =              "01;38;5;236"; # Mozilla XUL precompiled javacript
        ".nib" =                "38;5;57";    # macOS UI
        ".orig" =               "04;38;5;241"; # Undo files
        ".pbxproj" =            "1";          # Xcode files
        "*PkgInfo" =            "00;38;5;236"; # macOS app bundle id
        ".pyc" =                "01;38;5;236"; # Scum (python compiled)
        ".storyboard" =         "38;5;196";   # Xcode files
        ".strings" =            "1";          # Xcode files
        ".tg" =                 "00;38;5;236"; # telegram stuff ?
        ".vcard" =              "00;38;5;236"; # contact information
        ".vcf" =                "00;38;5;236"; # contact information
        ".xcconfig" =           "1";          # Xcode files
        ".xcsettings" =         "1";          # Xcode files
        ".xcuserstate" =        "1";          # Xcode files
        ".xcworkspacedata" =    "1";          # Xcode files
        # ┌───────────────────────────────────────────────────────────┐
        # │ Backup / temporary files                                  │
        # └───────────────────────────────────────────────────────────┘
        ".bak" =            "01;38;5;244"; # Backup / temporary files
        ".bck" =            "00;38;5;244"; # Backup / temporary files
        ".ii" =             "00;38;5;244"; # Backup / temporary files (gcc tmp file)
        ".sassc" =          "00;38;5;244"; # Backup / temporary files
        ".swo" =            "00;38;5;244"; # Backup / temporary files
        ".swp" =            "01;38;5;244"; # Backup / temporary files
        ".temp" =           "00;38;5;244"; # Backup / temporary files
        ".tmp" =            "00;38;5;244"; # Backup / temporary files
        # ┌───────────────────────────────────────────────────────────┐
        # │ Documentation                                             │
        # └───────────────────────────────────────────────────────────┘
        "*AUTHORS" =        "38;5;243;04"; # Documentation
        "*CHANGELOG" =      "38;5;243;04"; # Documentation
        "*CHANGELOG.md" =   "38;5;243;04"; # Documentation
        "*CHANGES" =        "38;5;243;04"; # Documentation
        "*CODEOWNERS" =     "38;5;243;04"; # Documentation
        "*CONTRIBUTING" =   "38;5;243;04"; # Documentation
        "*CONTRIBUTING.md" ="38;5;243;04"; # Documentation
        "*CONTRIBUTORS" =   "38;5;243;04"; # Documentation
        "*COPYING" =        "38;5;243;04"; # Documentation
        "*COPYRIGHT" =      "38;5;243;04"; # Documentation
        "*HISTORY" =        "38;5;243;04"; # Documentation
        "*INSTALL" =        "38;5;243;04"; # Documentation
        "*LICENSE" =        "38;5;243;04"; # Documentation
        "*LICENSE.md" =     "38;5;243;04"; # Documentation
        "*NOTICE" =         "38;5;243;04"; # Documentation
        "*PATENTS" =        "38;5;243;04"; # Documentation
        "*PKGBUILD" =       "00;38;5;60"; # Arch linux build
        "*README" =         "38;5;243;04"; # Documentation
        "*README.markdown" ="38;5;243;04"; # Documentation
        "*README*.md" =     "38;5;243;04"; # Documentation
        "*README.rst" =     "38;5;243;04"; # Documentation
        "*readme.txt" =     "38;5;243;04"; # Documentation
        "*README.txt" =     "38;5;243;04"; # Documentation
        "*TODO" =           "01;38;5;91"; # Todo list
        "*VERSION" =        "38;5;243;04"; # Documentation
    };
    enableZshIntegration = true;
    enableBashIntegration = true;
  };
}
