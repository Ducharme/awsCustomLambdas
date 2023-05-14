FROM node:18-alpine3.17
#FROM public.ecr.aws/lambda/nodejs:18
#RUN mkdir -p /home/node/app
#RUN chown -R node:node /home/node/app
#WORKDIR /home/node/app
COPY *.js package*.json ./
RUN npm install

#USER node
#CMD [ "node", "/home/node/app/main.js" ]
#CMD [ "node", "/home/node/app/index.js" ]
#CMD [ "node", "main.js" ]
#ENTRYPOINT [ "/usr/local/bin/node" ]
CMD ["index.handler"]
#CMD [ "node", "index.handler" ]
