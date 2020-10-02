FROM node:12.18-alpine as build
WORKDIR /usr/src/app
ENV PATH usr/src/app/node_modules/.bin:$PATH

COPY package*.json ./
RUN npm install
COPY . ./
RUN npm install -g @angular/cli nx
RUN nx run-many --target=build --all --parallel

FROM nginx:mainline as app

COPY ./nginx.conf /etc/nginx/nginx.conf
COPY --from=build /usr/src/app/dist/apps/test-app /usr/share/nginx/html
EXPOSE 80

FROM node:12.18-alpine as api
WORKDIR /app/api

COPY package*.json ./
RUN npm install
RUN npm install -g nodemon
COPY --from=build /usr/src/app/dist/apps/api /app/api

EXPOSE 3333
CMD [ "nodemon", "main.js" ]
