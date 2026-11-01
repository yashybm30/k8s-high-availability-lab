import "reflect-metadata";
import express from "express";
import { NestFactory } from "@nestjs/core";
import { AppModule } from "./app";
import { configure, port } from "./platform";
async function main() {
  const app = await NestFactory.create(AppModule, { bodyParser: false });
  app.use(express.json({ limit: "32kb" }));
  configure(app);
  await app.listen(port(), "0.0.0.0");
}
void main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
