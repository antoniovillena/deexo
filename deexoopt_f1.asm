;Exomizer 3 Z80 decoder
;Copyright (C) 2008-2018 by Jaime Tejedor Gomez (Metalbrain)
;
;Optimized by Antonio Villena and Urusergi
;
;Compression algorithm by Magnus Lind
;   exomizer raw -P13 -T0 (literals=1)
;   exomizer raw -P13 -T1 (literals=0)
;
;   This depacker is free software; you can redistribute it and/or
;   modify it under the terms of the GNU Lesser General Public
;   License as published by the Free Software Foundation; either
;   version 2.1 of the License, or (at your option) any later version.
;
;   This library is distributed in the hope that it will be useful,
;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;   Lesser General Public License for more details.
;
;   You should have received a copy of the GNU Lesser General Public
;   License along with this library; if not, write to the Free Software
;   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
;
      IF  mapbase-mapbase/256*256<240 AND mapbase-mapbase/256*256>135
        ld      iy, 256+mapbase/256*256
      ELSE
        ld      iy, (mapbase+16)/256*256+112
      ENDIF
        ld      a, 128
        ld      b, 52
        push    de
        cp      a
init    ld      c, 16
        jr      nz, get4
        ld      de, 1
        ld      ixl, c
get4    add     a, a
        call    z, getbit
        rl      c
        jr      nc, get4
      IF  mapbase-mapbase/256*256<240 AND mapbase-mapbase/256*256>135
        ld      (iy-256+mapbase-mapbase/256*256), c
      ELSE
        ld      (iy-112+mapbase-(mapbase+16)/256*256), c
      ENDIF
        push    hl
        ld      hl, 1
        defb    210
setbit  add     hl, hl
        dec     c
        jr      nz, setbit
      IF  mapbase-mapbase/256*256<240 AND mapbase-mapbase/256*256>135
        ld      (iy-204+mapbase-mapbase/256*256), e
        ld      (iy-152+mapbase-mapbase/256*256), d
      ELSE
        ld      (iy-60+mapbase-(mapbase+16)/256*256), e
        ld      (iy-8+mapbase-(mapbase+16)/256*256), d
      ENDIF
        add     hl, de
        ex      de, hl
        inc     iyl
        pop     hl
        dec     ixl
        djnz    init
        pop     de
litcop  ldi
mloop   add     a, a
        call    z, getbit
        jr      c, litcop
      IF  mapbase-mapbase/256*256<240 AND mapbase-mapbase/256*256>135
        ld      c, 256-1
      ELSE
        ld      c, 112-1
      ENDIF
getind  add     a, a
        call    z, getbit
        inc     c
        jr      nc, getind
    IF  mapbase-mapbase/256*256<240 AND mapbase-mapbase/256*256>135
        bit     4, c
      IF  literals=1
        jr      nz, litcat
      ELSE
        ret     nz
      ENDIF
    ELSE
      IF  literals=1
        jp      m, litcat
      ELSE
        ret     m
      ENDIF
    ENDIF
        push    de
        ld      iyl, c
        call    getpair
        push    de
      IF  mapbase-mapbase/256*256<240 AND mapbase-mapbase/256*256>135
        ld      bc, 512+48
        dec     e
        jr      z, goit
        dec     e
        ld      bc, 1024+32
        jr      z, goit
        ld      c, 16
      ELSE
        ld      bc, 512+160
        dec     e
        jr      z, goit
        dec     e
        ld      bc, 1024+144
        jr      z, goit
        ld      c, 128
      ENDIF
goit    call    getbits
        ld      iyl, c
        add     iy, de
        call    getpair
        pop     bc
        ex      (sp), hl
        push    hl
        sbc     hl, de
        pop     de
        ldir
        pop     hl
        jr      mloop

    IF  literals=1
litcat  
      IF  mapbase-mapbase/256*256<240 AND mapbase-mapbase/256*256>135
        rl      c
      ENDIF
        ret     pe
        ld      c, 1
litca1  add     a, a
        call    z, getbit
        rl      c
        rl      b
        jr      nc, litca1
        ldir
        jr      mloop
    ENDIF

      IF  mapbase-mapbase/256*256<240 AND mapbase-mapbase/256*256>135
getpair ld      b, (iy-256+mapbase-mapbase/256*256)
      ELSE
getpair ld      b, (iy-112+mapbase-(mapbase+16)/256*256)
      ENDIF
        call    getbits
        ex      de, hl
      IF  mapbase-mapbase/256*256<240 AND mapbase-mapbase/256*256>135
        ld      c, (iy-204+mapbase-mapbase/256*256)
        ld      b, (iy-152+mapbase-mapbase/256*256)
      ELSE
        ld      c, (iy-60+mapbase-(mapbase+16)/256*256)
        ld      b, (iy-8+mapbase-(mapbase+16)/256*256)
      ENDIF
        add     hl, bc
        ex      de, hl
        ret

getbits ld      de, 0
gbcont  dec     b
        ret     m
        add     a, a
        call    z, getbit
        rl      e
        rl      d
        jr      gbcont

getbit  ld      a, (hl)
        inc     hl
        adc     a, a
        ret