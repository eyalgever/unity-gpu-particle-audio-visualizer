using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MeshCreator : MonoBehaviour {
	Mesh mesh;
	public Material mat;
	// Use this for initialization
	const int size = 30;

	void Start () {
		
		

	}
	
	// Update is called once per frame
	void Update () {
		mesh = new Mesh();
		Vector3[] vertices = new Vector3[size* size];
		Vector2[] UVs = new Vector2[ size* size ];
		for(int i=0; i<size; i++){
			for(int j = 0; j< size; j++){
				vertices[i*size+j] = new Vector3(i, 0, j);

				float u = (float)i / (float)size;
				float v = (float)j / (float)size;

				UVs[i*size+j] = new Vector2(u,v);
			}
		}

		mesh.vertices = vertices;
		mesh.uv = UVs;
		mesh.subMeshCount = size;

		int[] indices = new int[size];
		for(int i=0; i<size; i++){ 
			for(int j=0; j<size; j++){
				indices[j] = i*size + j;
			}
			mesh.SetIndices(indices, MeshTopology.LineStrip, i);
		}
		
		

		mesh.bounds = new Bounds(Vector3.zero, Vector3.one * 1000);
		
		for(int i=0; i<mesh.subMeshCount; i++){
			Graphics.DrawMesh(mesh, Vector3.zero, Quaternion.identity, mat, 0, null, i);
		}

	}
}
