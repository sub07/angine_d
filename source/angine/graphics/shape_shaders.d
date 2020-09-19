module angine.graphics.shape_shaders;

immutable shapeVertexShader = `
#version 460

layout(location = 0) in vec2 vertexPosition;
layout(location = 1) in vec4 vertexColor;

out vec4 color;

uniform vec2 viewportSize;

void main() {
	vec2 workingVec = vec2(int(vertexPosition.x), int(vertexPosition.y));
	workingVec.x = workingVec.x * (2.0 / viewportSize.x) - 1.0;
	workingVec.y = workingVec.y * -(2.0 / viewportSize.y) + 1.0;
	gl_Position = vec4(workingVec, 0.0, 1.0);
	color = vertexColor;
}
`;

immutable shapeFragmentShader = `
#version 460

in vec4 color;

out vec4 finalPixelColor;

void main() {
    finalPixelColor = color;
}
`;
