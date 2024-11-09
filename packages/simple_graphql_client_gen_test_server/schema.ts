import * as g from "npm:graphql";
import { hello } from "./query/hello.ts";
import { now } from "./query/now.ts";
import { account } from "./query/account.ts";
import { union } from "./query/union.ts";

const query = new g.GraphQLObjectType({
  name: "Query",
  description: "データを取得できる. データを取得するのみで, データを変更しない",
  fields: {
    now,
    hello,
    account,
    union,
  },
});

const mutation = new g.GraphQLObjectType({
  name: "Mutation",
  description: "データを作成、更新ができる",
  fields: {
    now,
    union,
  },
});

export const schema = new g.GraphQLSchema({
  query,
  mutation,
});
