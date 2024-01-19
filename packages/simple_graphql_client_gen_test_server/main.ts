import { createHandler } from "npm:graphql-http/lib/use/fetch";
import { schema } from "./schema.ts";

Deno.serve(async (request) => {
  return await createHandler({
    schema,
  })(request);
});
