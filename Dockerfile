# Step 1: Use a Node image to build the app
FROM node:20-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json .

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

EXPOSE 3000

CMD [ "npm","start" ]