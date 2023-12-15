# read in data after PCA
adata = read.table(file="~/biostat625/CellTypeClassification/data/adata_pca.csv", header=TRUE, sep=",")  # 6321*50

# Step 1. MNN
kbatch = unique(adata$batch)
data = adata
cell_ref_id = which(data[, 'batch'] == kbatch[1])
k = 20
p = dim(adata)[2] - 2

for (clustnum in 2:length(kbatch)) {
  cell_add_id = which(data[, 'batch'] == kbatch[clustnum])
  result = MNN(data, cell_ref_id, cell_add_id, p)
  data = result$data
  cell_ref_id = result$ref_new
}

# Step 2. Kmeans
nclust = unique(adata$celltype)
cluster_result = kmeans(data[, 1:50], length(nclust))

# Step 3. evaluation
# Accuracy
accuracy <- eval_clustering_accuracy(adata$celltype, cluster_result$cluster)
print(accuracy)
# ARI
library(aricode)
ari_score <- ARI(adata$celltype, cluster_result$cluster)
print(ari_score)
# NMI
nmi_score <- NMI(adata$celltype, cluster_result$cluster)
print(nmi_score)



# umap visualization
# After MNN, according to clustering result
library(ggplot2)
library(umap)
cluster_out = cluster_result
umap_result = umap(data[, 1:50])
umap_data = cbind(umap_result$layout, Species = cluster_out$cluster)
# umap_data = cbind(umap_result$layout, Species = data$celltype)

umap_data_df = as.data.frame(umap_data)
umap_data_df$Species = as.character(umap_data_df$Species)
umap_data_df$Species = as.character(data$celltype)

ggplot(umap_data_df, aes(x = V1, y = V2, color = Species)) +
  geom_point(size = 0.8, shape = 16) +
  labs(title = "unsupervised assigenment",
       x = "V1",
       y = "V2") +
  theme_minimal()

ggplot(umap_data_df, aes(x = V1, y = V2, color = Species)) +
  geom_point(size = 0.8, shape = 16) +
  labs(title = "cell type",
       x = "V1",
       y = "V2") +
  theme_minimal()

ggplot(umap_data_df, aes(x = V1, y = V2, color = Species)) +
  geom_point(size = 0.8) +
  theme_minimal()
