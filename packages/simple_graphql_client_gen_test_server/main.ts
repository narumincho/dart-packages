import { createHandler } from "npm:graphql-http/lib/use/fetch";
import { schema } from "./schema.ts";

const server = Deno.serve({ port: 8000 }, async (request) => {
  return await createHandler({
    schema,
  })(request);
});

await server.finished;
