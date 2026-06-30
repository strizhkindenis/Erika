FROM alpine:latest AS builder

RUN apk add --no-cache openssh-server nginx busybox-suid

RUN mkdir -p /var/run/sshd /var/www/pastes
RUN rm -rf /etc/nginx/http.d/default.conf

COPY nginx.conf /etc/nginx/nginx.conf
COPY sshd_config /etc/ssh/sshd_config
COPY entrypoint.sh /entrypoint.sh
COPY server_paste /usr/local/bin/server_paste

RUN adduser -D paste
RUN passwd -u paste
RUN mkdir -p /home/paste/.ssh
RUN chown -R paste:paste /home/paste/.ssh
RUN chmod 700 /home/paste/.ssh
RUN chmod +x /usr/local/bin/server_paste /entrypoint.sh
RUN chown -R paste:nginx /var/www/pastes && chmod 750 /var/www/pastes


FROM alpine:latest

COPY --from=builder / /

EXPOSE 22 80

ENTRYPOINT ["/entrypoint.sh"]
