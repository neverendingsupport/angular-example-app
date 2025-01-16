# Start with a Python 2.7 base image
FROM python:2.7

# Set the working directory in the container
WORKDIR /app

# Use bash as the shell
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Update the repository sources list and install dependencies
RUN apt-get update \
    && apt-get install -y curl \
    && apt-get -y autoclean

# nvm environment variables
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 12.13.0

# Install nvm
RUN curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.2/install.sh | bash

# Install Node.js and upgrade npm to v8.19.4
RUN source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default \
    && npm install -g npm@8.19.4

# Add Node.js and npm to PATH
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Confirm Node.js and npm versions
RUN node -v
RUN npm -v

# Install Angular CLI globally inside the container
RUN npm install -g @angular/cli@9.1.13

# Copy project files into the container
COPY . .

# Install any needed packages specified in package.json
RUN npm install

# Build the Angular application
RUN npm run build || exit 1

# Expose port 4200 to the world outside this container
EXPOSE 4200

# Run the app when the container launches
CMD ["ng", "serve", "--host", "0.0.0.0"]