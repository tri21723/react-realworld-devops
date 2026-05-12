FROM node:16-alpine

WORKDIR /app

# Install dependencies first for better caching
COPY package.json package-lock.json* ./
RUN npm install --legacy-peer-deps

# Copy the rest of the app source code
COPY . .

# Expose port 4100 as configured in the app
EXPOSE 4100

# Start the app
CMD ["npm", "start"]
