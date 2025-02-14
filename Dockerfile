# Start with a Python 2.7 base image
FROM python:2.7

# Set the working directory in the container
WORKDIR /app

# Install Node.js
# replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# update the repository sources list
# and install dependencies
RUN apt-get update \
    && apt-get install -y curl \
    && apt-get -y autoclean

# nvm environment variables
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 16.20.2

# install nvm
# https://github.com/creationix/nvm#install-script
RUN curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.2/install.sh | bash

# install node and npm
RUN source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

# add node and npm to path so the commands are available
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# ARG instruction defines a variable that users can pass at build-time to the builder with the docker build command.
ARG NES_AUTH_TOKEN

# Use the shell form to dynamically create the .npmrc file using the argument (NES_AUTH_TOKEN)
RUN echo "@neverendingsupport:registry=https://registry.nes.herodevs.com/npm/pkg/" > .npmrc && \
    echo "//registry.nes.herodevs.com/npm/pkg/:_authToken=${NES_AUTH_TOKEN}" >> .npmrc
    
# Confirm Node.js and npm are installed
RUN node -v
RUN npm -v

# Set npm version to a version where transitive dependencies can be correctly overridden
RUN npm install -g npm@8.19.4

# Install Angular CLI globally inside the container
RUN npm install -g @angular/cli@8.2.1

# Copy the project files into the container at /app
COPY . .

# Install any needed packages specified in package.json
RUN npm install --legacy-peer-deps

# Build your Angular application
# RUN npm run build || exit 1

# Make port 4200 available to the world outside this container
EXPOSE 4200

# Build the app
RUN ng build --configuration=production --base-href /ocm/ --deploy-url /

# Serve the app
RUN npm install -g http-server
CMD ["http-server", "/app", "-p", "8080", "--cors", "--gzip"]

# Run the app when the container launches
# CMD ["ng", "serve", "--host", "0.0.0.0"]
# CMD ["tail", "-f", "/dev/null"]
