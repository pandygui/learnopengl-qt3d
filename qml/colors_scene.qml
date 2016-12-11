import Qt3D.Core 2.0
import Qt3D.Render 2.0
import Qt3D.Input 2.0
import Qt3D.Extras 2.0

import "Components"
import "VirtualKey"

Scene2 {
	id: scene
	children: VirtualKeys {
		target: scene
		enableGameButtons: false
		color: "transparent"
		centerItem: RowKeys {
			keys: [
				{text:"Space", key:Qt.Key_Space}
			]
		}
	}

	Entity {
		id: root

		RenderSettings1 {}

		InputSettings {}

		OurCameraController {
			camera: root.camera
			mouseSensitivity: 0.5 / Units.dp
		}

		KeyboardDevice {
			id: keyboardDevice
		}

		KeyboardHandler {
			id: keyboardHandler
			sourceDevice: keyboardDevice
			focus: true

			onSpacePressed: {
				root.useQtCameraAndMesh = !root.useQtCameraAndMesh
				console.log("useQtCameraAndMesh:", root.useQtCameraAndMesh)
			}
		}

		Entity {
			id: ourCamera

			property real yaw: 0
			property real pitch: 0
			property real fieldOfView: 45

			property vector3d position: "0,0,3"
			property vector3d viewCenter: position.plus(frontVector)
			property vector3d upVector: "0,1,0"
			property vector3d frontVector: Qt.vector3d(
				Math.cos(pitch * Math.PI / 180.) * Math.sin(yaw * Math.PI / 180.),
				-Math.sin(pitch * Math.PI / 180.),
				-Math.cos(pitch * Math.PI / 180.) * Math.cos(yaw * Math.PI / 180.)
			)
			property vector3d rightVector: frontVector.crossProduct(upVector).normalized()

			property matrix4x4 viewMatrix: {
				var m = Qt.matrix4x4()
				m.lookAt(position, viewCenter, upVector)
				return m
			}

			property matrix4x4 projectionMatrix: {
				var aspect = scene.width / scene.height
				var zNear = .1
				var zFar = 100.
				var h = Math.tan(fieldOfView * Math.PI / 360) * zNear
				var w = h * aspect

				var m = Qt.matrix4x4()
				m.m11 = zNear / w
				m.m22 = zNear / h
				m.m33 = - (zNear + zFar) / (zFar - zNear)
				m.m34 = -2 * zNear * zFar / (zFar - zNear)
				m.m43 = -1
				m.m44 = 0
				return m
			}
		}

		Camera {
			id: qtCamera

			projectionType: CameraLens.PerspectiveProjection
			fieldOfView: 45  // Projection
			aspectRatio: scene.width/scene.height
			nearPlane : 0.1
			farPlane : 100.0
			position: "0,0,3"// View
			viewCenter: "0,0,0"
			upVector: "0,1,0"
		}

		property bool useQtCameraAndMesh: false

		property Entity camera: useQtCameraAndMesh?qtCamera:ourCamera

		property color objectColor: "coral"
		property color lightColor: "white"

		TextureCubeGeometry0 {
			id: geometry
		}

		CuboidMesh {
			id: mesh
		}

		Entity {
			id: object

			Transform {
				id: objectTransform
			}

			Material {
				id: objectMaterial
				effect: Effect {
					techniques: Technique {
						renderPasses: RenderPass {
							shaderProgram: ShaderProgram0 {
								vertName: "lighting"
								fragName: "lighting"
							}
							parameters: [
								Parameter {
									name: "viewMatrix"
									value: root.camera.viewMatrix
								},
								Parameter {
									name: "projectionMatrix"
									value: root.camera.projectionMatrix
								},
								Parameter {
									name: "objectColor"
									value: Qt.vector3d(
										root.objectColor.r,
										root.objectColor.g,
										root.objectColor.b
									)
								},
								Parameter {
									name: "lightColor"
									value: Qt.vector3d(
										root.lightColor.r,
										root.lightColor.g,
										root.lightColor.b
									)
								}
							]
						}
					}
				}
			}

			components: [root.useQtCameraAndMesh?mesh:geometry,
				objectTransform, objectMaterial
			]
		}

		Entity {
			id: lamp

			Transform {
				id: lampTransform
				translation: Qt.vector3d(1.2, 1.0, 2.0)
				scale: .2 // Use scale to decrease lamp size
			}

			Material {
				id: lampMaterial
				effect: Effect {
					techniques: Technique {
						renderPasses: RenderPass {
							shaderProgram: ShaderProgram0 {
								vertName: "lighting"
								fragName: "shaders-uniform"
							}
							parameters: [
								Parameter {
									name: "viewMatrix"
									value: root.camera.viewMatrix
								},
								Parameter {
									name: "projectionMatrix"
									value: root.camera.projectionMatrix
								},
								Parameter {
									name: "ourColor"
									value: root.lightColor
								}
							]
						}
					}
				}
			}

			components: [root.useQtCameraAndMesh?mesh:geometry,
				lampTransform, lampMaterial
			]
		}
	}
}