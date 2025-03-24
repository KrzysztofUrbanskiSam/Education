// A schema is a collection of type definitions (hence "typeDefs")
// that together define the "shape" of queries that are executed against
// your data.

export const typeDefs = `#graphql

    type Game {
        id: ID! # ! means field is required
        title: String!
        platform: [String!]!
    }

    type Review {
        id: ID!
        rating: Int!
        content: String!
    }

    type Author {
        id: ID!
        name: String!
        verified: Boolean!
    }

    # Mandatory field where user can land
    type Query {
        reviews: [Review]
        games: [Game]
        authors: [Author]
    }
`;

//Available types: int, float, string, boolean, ID
