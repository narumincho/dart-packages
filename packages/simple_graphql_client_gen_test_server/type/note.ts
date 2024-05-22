import * as g from "npm:graphql";

export type Note = {
  readonly description: string;
  readonly subNotes: ReadonlyArray<Note>;
};

export const Note: g.GraphQLObjectType = new g.GraphQLObjectType({
  name: "Note",
  description: "ノート",
  fields: () => ({
    description: {
      description: "説明文",
      type: new g.GraphQLNonNull(g.GraphQLID),
    },
    subNotes: {
      description: "子ノート",
      type: new g.GraphQLNonNull(new g.GraphQLList(new g.GraphQLNonNull(Note))),
    },
  }),
});
