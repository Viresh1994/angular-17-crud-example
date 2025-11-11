# Use a lightweight Node.js base image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files first (for better caching)
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy the rest of the app code
COPY . .

# Build the TypeScript app (if applicable)
RUN npm run build

# Expose the app port (change if your app uses a different port)
EXPOSE 3000

# Start the app
CMD ["npm", "start"]
