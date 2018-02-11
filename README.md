# Smalltalk 76

These sources were recovered from [xmsmall.dsk](http://www.bitsavers.org/bits/Xerox/Alto/disk_images/chm/xmsmall.zip).  The following steps were performed using the [Contralto emulator](https://github.com/livingcomputermuseum/ContrAlto):

1. Copy `xmsmall.dsk` to `blank.dsk`
2. In Contralto, insert `blank.dsk` in disk pack 0.
3. Boot the system
4. In the Alto Executive, execute: `delete Smalltalk.Sources.5.5k xmsmall.boot`
5. Restart Contralto, inserting `xmsmall.dsk` in disk pack 0, `blank.dsk` in disk pack 1.
6. Boot the system
7. In the Alto Executive, execute `resume xmsmall.boot`
8. Once the Smalltalk UI appears, use the System Browser. 
9. In System Browser's left-most column, select `Sets and Dictionaries`
10. In the second column, select `SystemOrganizer`
11. In the third column, select `Filout and printing`
12. In the fourth column, select `printAll`
13. In the bottom pane, replace:
  * `printAll` with `filoutAll`
  * `printCategory` with `filoutCategory`
14. Middle click in the bottom pane, and select `Compile`. A new method, `filoutAll` should appear in the fourth column.
15. In the fourth column, select `filoutCategory:`
16. In the bottom pane, replace `dp0` with `dp1`
17. Middle click in the bottom pane, and select `Compile`
18. In the bottom pane, type `SystemOrganization filoutAll`
19. Select the text `SystemOrganization filoutAll`
20. Middle click the text selection, and select `Do it`
21. As each category is written to disk, it will appear in the upper left hand corner of the screen in the `UserView`.  This process will take some time.
22. Once completed, stop Contralto.
23. Use [aar](http://www.bitsavers.org/bits/Xerox/Alto/tools/aar.c) to extract the files from blank.dsk. e.g. `aar x blank.dsk`
24. Use `dd` to fix the byte ordering in the files. e.g. `for f in *.st; do dd if=$f of=$f.tmp conv=swab; mv $f.tmp $f; done`
25. At this stage, the files should resemble the first commit in this repo.
26. [restore_alto_files](http://xeroxalto.computerhistory.org/src/restore_alto_files.tar.gz) can be used to generate HTML from these files.
27. Replace the low ASCII characters with variants modern OSes can use via:
```
perl -pi -e 's/\x01/≤/g' *.st
perl -pi -e 's/\x03/⦂/g' *.st
perl -pi -e 's/\x06/≡/g' *.st
perl -pi -e 's/\x07/◦/g' *.st
perl -pi -e 's/\x0e/≠/g' *.st
perl -pi -e 's/\x0f/↪/g' *.st
perl -pi -e 's/\x11/⇑/g' *.st
perl -pi -e 's/\x12/≥/g' *.st
perl -pi -e 's/\x13/ⓢ/g' *.st
perl -pi -e 's/\x15/¬/g' *.st
perl -pi -e 's/\x16/∢/g' *.st
perl -pi -e 's/\x17/⌾/g' *.st
perl -pi -e 's/\x18/▱/g' *.st
perl -pi -e 's/\x19/➲/g' *.st
perl -pi -e 's/\x1b/⇒/g' *.st
perl -pi -e 's/_/←/g' *.st
```
