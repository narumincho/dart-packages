import * as g from "npm:graphql";
import { Account } from "../type/account.ts";
import { Note } from "../type/note.ts";

const AccountOrNote = new g.GraphQLUnionType({
  name: "AccountOrNote",
  types: [Account, Note],
});

export const union: g.GraphQLFieldConfig<
  void,
  unknown,
  { readonly id: string }
> = {
  args: {
    id: {
      type: new g.GraphQLNonNull(g.GraphQLID),
      description: "取得するアカウントのID",
    },
  },
  type: new g.GraphQLNonNull(AccountOrNote),
  resolve: (_, { id }): Account => {
    return {
      id,
      name: "sample account name from union",
    };
  },
  description: "IDからアカウントもしくはノートを取得",
};
