FROM node:19-bullseye-slim AS builder

WORKDIR /app
COPY package*.json ./

RUN npm install

COPY . .

# Remove devDependencies to keep the footprint small
RUN npm prune --production

#######################################################################

# Production (The tiny version)
FROM node:19-alpine

LABEL fly_launch_runtime="nodejs"

WORKDIR /app
ENV NODE_ENV production
ENV PORT 4444

# Copy the pruned production node_modules
COPY --from=builder /app/node_modules ./node_modules

COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/ .

EXPOSE 4444

CMD [ "node", "./bin/server.js" ]