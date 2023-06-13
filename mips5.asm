.data
	coefs: .float 2.3 3.45 7.67 5.32
	degree: .word 3
	questionString: .asciiz "\nPodaj wartosc X do obliczenia wielomianu: (zero aby wyjsc)\n"

.text

mainLoop:
	li  $v0, 4 		# Kod print String
	la  $a0, questionString	# Adres Stringa do wyswietlenia
	syscall
	li  $v0, 6 		# Wczytaj float z konsoli (wartosc w $f0)
	syscall
	la $s0, coefs		# W $s0 podaje adres poczatku tablicy wspolczynnikow
	lw $s1, degree 		# W $s1 podaje stopien wielomianu
	mfc1 $t0, $f0		# Pobieram podana wartosc do sprawdzenia czy jest 0
	mov.s $f12, $f0 	# Zapisuje wartosc X jako $f12 (zgodnie z konwencja)
	beqz $t0, exit 		# Jezeli podano 0 wyjdz z programu
	jal eval_poly		# Wykonaj podprogram (2 warunki aby uzyc jump and link, zgodnie z konwencja), wedlug polecenia interakcja z konsola tylko w main
	li $v0, 2		# Wyswietlenie wartosci typu float, dla double jest 3
	#movf.d $f12, $f0	# Opcja gdybyœmy chcieli wyœwietlaæ typ double
	cvt.s.d $f12, $f0 	# Zapisz wynik podprogramu do $f12 jako float (zgodnie z poleceniem)
	syscall 		# Wyswietl wynik
	j mainLoop		# Powrot do petli


# eval poly:
# stopien = lw degree ($s1)
# suma = lw (coefsAdress)
# loop:
#	wspolczynnik = lw (coefsAdress)
#	suma = suma *x
#	suma = suma + wspolczynnik
#	coefsAdress = coefsAdress + 4
#	stopien = stopien - 1
#	if (stopien>0) goto loop
# goto mainLoop

eval_poly:
	# Argumenty wejsciowe:
	# $s0 - adres poczatku tablicy wspolczynnikow
	# $s1 - stopien wielomianu
	# $f12 - wartosc X
	# Zmienne:
	# $f0 - wynik funckji ( suma wielomianu )
	# $f4 - wspolczynnik
	lwc1 $f0, ($s0)			# Wartosc poczotkowa sumy to pierwszy wspolczynnik
	beqz $s1, koniec		# Jezeli stopien wielomianu to 0, nie wykonuje petli. Mam juz sume.
	cvt.d.s $f0, $f0 		# Konwertuje sume do podwojnej precyzji
	loop: 				# Obliczenie wielomianow metoda Hornera
		addi    $s0, $s0, 4 	# Przesuwam adres wspolczynnika do dczytania na nastepny wspolczynnik
		lwc1    $f4, ($s0) 	# Wczytuje wspolczynnik
		cvt.d.s $f10, $f12 	# X w podwojnej precyzji do obliczenia
		mul.d   $f0, $f0, $f10 	# Suma = Suma * x
		cvt.d.s $f10, $f4 	# wspolczynnik w podwojnej precyzji do obliczenia
		add.d   $f0, $f0, $f10 	# Suma = Suma + wspolczynnik
		subi    $s1, $s1, 1 	# Stopien = stopien - 1 (do nastepnego sprawdzenia)
		bgtz    $s1, loop 	# Jezeli stopien > 0 to nie obliczylismy jeszcze calej sumy
	
	
	#koniec podprogramu
	koniec: jr $ra		# Powrot do petli
		

exit:
	li   $v0, 10 		
	syscall
