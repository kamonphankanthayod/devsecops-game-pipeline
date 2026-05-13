# Use the official Node.js 16 image as the base image
FROM node:16

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json (or yarn.lock) to the container
COPY package*.json ./

# Install project dependencies
RUN npm install

# Copy the rest of the application code to the container
COPY . .

# Build the React app
RUN npm run build

# Expose the port that the app will run on (usually 3000 by default)
EXPOSE 3000

# Create pod.js at container runtime, then start React app
CMD sh -c "echo \"window.POD_NAME='${POD_NAME}';\" > /app/public/pod.js && echo \"window.NODE_NAME='${NODE_NAME}';\" >> /app/public/pod.js && npm start"
