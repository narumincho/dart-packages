import * as g from "npm:graphql";
import { Account } from "../type/account.ts";

export const account: g.GraphQLFieldConfig<
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
  type: Account,
  resolve: (_, { id }): Account => {
    return {
      id,
      name: "sample account name",
    };
  },
  description: "IDからアカウントを取得",
};
