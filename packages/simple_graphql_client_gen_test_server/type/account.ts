import * as g from "npm:graphql";

export type Account = {
  readonly __typename: "Account";
  readonly id: string;
  readonly name: string;
};

export const Account = new g.GraphQLObjectType({
  name: "Account",
  description: "よくあるアカウントの型",
  fields: {
    id: {
      description: "識別するためのID",
      type: new g.GraphQLNonNull(g.GraphQLID),
    },
    name: {
      description: "名前",
      type: g.GraphQLString,
    },
  },
});
