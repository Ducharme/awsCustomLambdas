FROM node:18-alpine3.17
RUN mkdir -p /home/node/app
#RUN chown -R node:node /home/node/app
WORKDIR /home/node/app
COPY *.js package.json ./
#USER node
#CMD [ "node", "/home/node/app/main.js" ]
#CMD [ "node", "/home/node/app/index.js" ]
#CMD [ "node", "main.js" ]
#ENTRYPOINT [ "/usr/local/bin/node" ]
#CMD ["index.handler"]
CMD [ "node", "index.handler" ]
