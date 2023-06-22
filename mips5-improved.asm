.data
	coefs:   .float 2.3 3.45 7.67 5.32
	degree:  .word  3
	qString: .asciiz "\nPodaj wartosc X do obliczenia wielomianu: (zero aby wyjsc)\n"

.text

mainLoop:
	li    $v0, 4 		# Kod print String
	la    $a0, qString	# Adres Stringa do wyswietlenia
	syscall
	li    $v0, 6 		# Wczytaj float z konsoli (wartosc w $f0)
	syscall
	mfc1  $t0, $f0		# Pobieram podana wartosc do sprawdzenia czy jest 0
	beqz  $t0, exit 		# Jezeli podano 0 wyjdz z programu
	la    $a0, coefs		# W $a0 podaje adres poczatku tablicy wspolczynnikow
	lw    $a1, degree 	# W $a1 podaje stopien wielomianu
	mov.s $f12, $f0 		# Zapisuje wartosc X jako $f12 (zgodnie z konwencja)
	jal   eval_poly		# Wykonaj podprogram (2 warunki aby uzyc jump and link, zgodnie z konwencja), wedlug polecenia interakcja z konsola tylko w main
	li    $v0, 2		# Wyswietlenie wartosci typu float, dla double jest 3
	cvt.s.d $f12, $f0 	# Zapisz wynik podprogramu do $f12 jako float (zgodnie z poleceniem)
	syscall 			# Wyswietl wynik
	j mainLoop		# Powrot do petli


# eval poly:
# stopien = lw degree ($a1)
# suma = lw (coefsAdress)
# loop:
#	coefsAdress = coefsAdress + 4
#	wspolczynnik = lw (coefsAdress)
#	suma = suma *x
#	suma = suma + wspolczynnik
#	stopien = stopien - 1
#	if (stopien>0) goto loop
# goto mainLoop

eval_poly:
	# Argumenty wejsciowe:
	# $a0 - adres poczatku tablicy wspolczynnikow
	# $a1 - stopien wielomianu
	# $f12 - wartosc X
	# Zmienne:
	# $f0 - wynik funckji ( suma wielomianu )
	# $f4 - wspolczynnik
	lwc1 $f0, ($a0)		# Wartosc poczotkowa sumy to pierwszy wspolczynnik
	cvt.d.s $f0, $f0 	# Konwertuje sume do podwojnej precyzji
	beqz $a1, koniec		# Jezeli stopien wielomianu to 0, nie wykonuje petli. Mam juz sume.
	cvt.d.s $f10, $f12 	# X w podwojnej precyzji do obliczenia
	#finalna wartosc $a0 to poczatkowa + 4*stopien
	sll $s1, $a1, 2 		# Wspolczynnik*4 do obliczenia wartosci finalnej
	add $s1, $s1, $a0

	loop: 				# Obliczenie wielomianow metoda Hornera
		addi    $a0, $a0, 4 	# Przesuwam adres wspolczynnika do dczytania na nastepny wspolczynnik
		lwc1    $f4, ($a0) 	# Wczytuje wspolczynnik
		mul.d   $f0, $f0, $f10 	# Suma = Suma * x
		cvt.d.s $f8, $f4 	# wspolczynnik w podwojnej precyzji do obliczenia
		add.d   $f0, $f0, $f8 	# Suma = Suma + wspolczynnik
		bne 	$s1, $a0, loop 	# Jezeli adres == finalnyadres to koniec petli
	
	#koniec podprogramu
	koniec: jr $ra		# Powrot do petli
		

exit:
	li   $v0, 10 		
	syscall
