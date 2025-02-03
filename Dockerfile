
# Uso una imagen base de Apache
FROM httpd:2.4

# Instalo Node.js y json-server
RUN apt-get update && \
    apt-get install -y npm nodejs

# Habilito mod_userdir para el espacio de usuarios
RUN sed -i 's/#LoadModule userdir_module/LoadModule userdir_module/' /usr/local/apache2/conf/httpd.conf && \
    echo "IncludeOptional conf/extra/httpd-userdir.conf" >> /usr/local/apache2/conf/httpd.conf

# Copio la configuración de UserDir
COPY ./tf/httpd-userdir.conf /usr/local/apache2/conf/extra/

# Copio los archivos de la página web
COPY ./index.es.html /usr/local/apache2/htdocs/
COPY ./index.en.html /usr/local/apache2/htdocs/
COPY ./docs/ /usr/local/apache2/htdocs/docs/
COPY ./css/ /usr/local/apache2/htdocs/css/
COPY ./js/ /usr/local/apache2/htdocs/js/
COPY ./db/ /usr/local/apache2/htdocs/db/

# Copio los certificados SSL
COPY ./tf/certificate.crt /usr/local/apache2/conf/
COPY ./tf/ca_bundle.crt /usr/local/apache2/conf/
COPY ./tf/private.key /usr/local/apache2/conf/

# Configuración SSL personalizada
COPY ./tf/httpd-ssl.conf /usr/local/apache2/conf/extra/

# Habilito SSL
RUN apt-get install -y ssl-cert && \
    sed -i 's/#LoadModule ssl_module/LoadModule ssl_module/' /usr/local/apache2/conf/httpd.conf && \
    echo "Include /usr/local/apache2/conf/extra/httpd-ssl.conf" >> /usr/local/apache2/conf/httpd.conf

# Exponer puertos
EXPOSE 80
EXPOSE 443

# Instrucción por defecto
CMD ["httpd-foreground"]
