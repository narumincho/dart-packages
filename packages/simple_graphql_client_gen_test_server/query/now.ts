import { DateTime } from "jsr:@narumincho/simple-graphql-server";
import * as g from "npm:graphql";

export const now: g.GraphQLFieldConfig<void, unknown, unknown> = {
  args: {},
  type: new g.GraphQLNonNull(DateTime),
  resolve: (): Date => {
    return new Date();
  },
  description: "サーバーでの現在時刻を取得する",
};
