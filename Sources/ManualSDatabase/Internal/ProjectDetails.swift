// import Fluent
// import FluentSQL
// import ManualSModels
//
// extension ManualSDatabase.ProjectDetails {
//
//   static func live(on database: any Database) -> Self {
//     .init(
//       fetch: { projectID in
//         let model = try await DesignInfoModel.query(on: database)
//           .filter(\DesignInfoModel.$projectID == projectID.rawValue)
//           .join(
//             HouseLoadModel.self,
//             on: \DesignInfoModel.$projectID == \HouseLoadModel.$projectID
//           )
//           // .join(
//           //   .self,
//           //   on: \DesignInfoModel.$projectID == \HouseLoadModel.$projectID
//           // )
//         // .join(HouseLoadModel.self, on: \HouseLoadModel.$projectID == projectID.rawValue)
//         return nil
//       }
//     )
//   }
// }
//
// private struct DetailIntermediate: Decodable {
//   let designInfo: DesignInfoModel?
//   let houseLoad: HouseLoadModel?
// }
