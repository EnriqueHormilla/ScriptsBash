#! /bin/bash
#Defino el limite de temperatura para el aviso:
templimite=60

#Obtengo la temperatura para el aviso por mail:
tempmail=$(/opt/vc/bin/vcgencmd measure_temp | cut -d = -f 2)
#Obtengo el valor de temperatura a comparar (tiene que ser un valor entero):
temp=$(echo $tempmail | cut -d '.' -f 1)
#Compruebo si el fichero ftemp.txt está creado y sino lo creo asignándole  un valor 0:

            if [ -f /home/pi/ftemp.txt ]
			then 
				read VARtemp < /home/pi/ftemp.txt #Asignamos un valor 0 o 1 a VARtemp desde el fichero ftemp.txt
			else
				echo 0 > /home/pi/ftemp.txt
			read VARtemp < /home/pi/ftemp.txt
			fi
#Defino la condición , si la temperatura es superior al limite y el valor de VARtemp es 0, manda  un mail de  aviso de temperatura critica:
			if [ $temp -ge $templimite ] && [ $VARtemp = 0 ]
            then
                    echo "Alerta!!!, la temperatura de la CPU ha superado el umbral de $templimite C, la temperatura actual es de $tempmail"  | mail -s "Alerta!!! Temperatura Crítica $tempmail" enriquehormillaaragon@gmail.com
					echo 1 > /home/pi/ftemp.txt
	fi
#Defino la condición, si la temperatura es inferiror al límite y el valor de VARtemp es 1, manda un mail de aviso de temperatura corregida:
			if [ $temp -lt $templimite ] && [ $VARtemp = 1 ]
	then
					echo "Corregido!!!, la temperatura de la CPU ha vuelto a valores normales, la temperatura actual es de $tempmail"  | mail -s "Corregida!!! temperatura actual  $tempmail" enriquehormillaaragon@gmail.com
					echo 0 > /home/pi/ftemp.txt
			fi
