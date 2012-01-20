SSO + Autenticación de servicios Rest (con OAuth)
-------------------------------------------------

[Protocolo OAuth 1](http://tools.ietf.org/html/rfc5849)

## SSO

## Autenticación entre applicaciones (OAuth 2 legged)

Se requiere que las applicaciones se puedan comunicar entre si, a través de REST.  El objetivo es no generar una API aparte sino poder consumir los servicios que entregan los controllers consumiendo JSON.
Se generará un componente que podrá determinar si el usuario posee session (en el caso de que un usuario a través de un browser accede al controller) o si se intenta consumir un recurso desde otra aplicación (web service REST).  En el segundo caso se implementa la firma de la petición (request) mediante la utilización de OAuth.  Básicamente al aplicación consumidora posee dos claves, una pública y otra privada que comparte con el proveedor. Se genera una firma (sign) con la unión de los datos del request + la clave pública + la clave privada (la clave pública viaja en el header del request, la clave privada jamas viaja en el request).  El proveedor genera la firma del mismo modo y verifica que sean iguales.

Se genera, además, un módulo para facilitar el consumo de recursos remotos (Rest)

## Ideas y pendientes

* Convertir todo en una gema.
* Generar un middleware rack para procesar la firma del request (en vez de tener el código en el controller)
