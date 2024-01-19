import * as g from "npm:graphql";

export const hello: g.GraphQLFieldConfig<void, unknown, unknown> = {
  args: {},
  type: new g.GraphQLNonNull(g.GraphQLString),
  resolve: (): string => {
    return "Hello GraphQL";
  },
  description: "挨拶をする",
};
