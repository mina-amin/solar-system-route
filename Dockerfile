FROM node:18-alpine3.17

WORKDIR /usr/app

COPY package*.json /usr/app/

RUN npm install

COPY . .

ENV MONGO_URI=mongodb+srv://supercluster.d83jj.mongodb.net/superData
ENV MONGO_USERNAME=$MONGO_USERNAME
ENV MONGO_PASSWORD=$MONGO_PASSWORD

EXPOSE 3000

CMD [ "npm", "start" ]